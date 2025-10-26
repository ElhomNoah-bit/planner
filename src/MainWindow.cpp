#include "MainWindow.h"
#include "ExamDialog.h"

#include "models/TaskFilterProxy.h"
#include "models/TaskModel.h"
#include "ui/TaskDelegate.h"
#include "ui/ToastManager.h"
#include "ui/views/MonthView.h"

#include <QAbstractItemView>
#include <QAction>
#include <QCheckBox>
#include <QDate>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QListView>
#include <QListWidget>
#include <QListWidgetItem>
#include <QMessageBox>
#include <QPalette>
#include <QPushButton>
#include <QResizeEvent>
#include <QSignalBlocker>
#include <QSplitter>
#include <QToolBar>
#include <QVBoxLayout>
#include <algorithm>

MainWindow::MainWindow(QWidget* parent)
	: QMainWindow(parent) {
	setWindowTitle("Noah Planner v2.0");
	resize(1200, 800);

	m_themeManager = new ThemeManager(this);
	buildUi();
	applyTheme(m_state.darkTheme());
	applyStateToUi();
	updateFilters();

	refreshToday();
	renderExams();
}

MainWindow::~MainWindow() {
	saveState();
}

void MainWindow::buildUi() {
	auto* toolbar = addToolBar("Main");
	auto* todayAct = toolbar->addAction("Heute");
	connect(todayAct, &QAction::triggered, this, [this] {
		refreshToday();
	});

	m_darkModeAction = toolbar->addAction("Dunkel");
	m_darkModeAction->setCheckable(true);
	m_darkModeAction->setChecked(m_state.darkTheme());
	connect(m_darkModeAction, &QAction::toggled, this, &MainWindow::onThemeToggled);

	toolbar->addSeparator();
	toolbar->addWidget(new QLabel("Suche:"));
	m_search = new QLineEdit(this);
	m_search->setPlaceholderText("Thema/Fach…");
	m_search->setClearButtonEnabled(true);
	toolbar->addWidget(m_search);

	m_onlyOpen = new QCheckBox("Nur offene", this);
	toolbar->addWidget(m_onlyOpen);

	auto* subjectBox = new QGroupBox("Fächerfilter", this);
	auto* subjectLayout = new QHBoxLayout(subjectBox);
	subjectLayout->setSpacing(8);
	for (const auto& subject : m_planner.subjects()) {
		auto* cb = new QCheckBox(subject.name, this);
		cb->setChecked(false);
		subjectLayout->addWidget(cb);
		m_subjectFilter.insert(subject.id, cb);
		connect(cb, &QCheckBox::toggled, this, &MainWindow::onSubjectFilterChanged);
	}
	toolbar->addSeparator();
	toolbar->addWidget(subjectBox);

	auto* central = new QWidget(this);
	setCentralWidget(central);
	auto* split = new QSplitter(Qt::Horizontal, central);
	split->setChildrenCollapsible(false);

	auto* monthContainer = new QWidget(split);
	auto* monthLayout = new QVBoxLayout(monthContainer);
	monthLayout->setContentsMargins(0, 0, 0, 0);
	monthLayout->setSpacing(12);
	auto* monthTitle = new QLabel("Monatsansicht", monthContainer);
	monthTitle->setObjectName("monthViewTitle");
	monthTitle->setStyleSheet("font-size: 18px; font-weight: 600;");
	monthLayout->addWidget(monthTitle);

	m_monthView = new MonthView(monthContainer);
	m_monthView->setPlanner(&m_planner);
	m_monthView->setMonth(QDate::currentDate());
	monthLayout->addWidget(m_monthView, 1);

	split->addWidget(monthContainer);
	connect(m_monthView, &MonthView::daySelected, this, &MainWindow::refreshDay);

	auto* right = new QWidget(split);
	auto* rightLayout = new QVBoxLayout(right);
	rightLayout->setContentsMargins(0, 0, 0, 0);
	rightLayout->setSpacing(12);

	auto* todayBox = new QGroupBox("Heute", right);
	auto* todayLayout = new QVBoxLayout(todayBox);
	todayLayout->setSpacing(8);
	m_progress = new QLabel("0/0", todayBox);
	todayLayout->addWidget(m_progress);

	m_taskModel = new TaskModel(this);
	m_taskProxy = new TaskFilterProxy(this);
	m_taskProxy->setSourceModel(m_taskModel);
	m_taskDelegate = new TaskDelegate(this);

	m_todayView = new QListView(todayBox);
	m_todayView->setModel(m_taskProxy);
	m_todayView->setItemDelegate(m_taskDelegate);
	m_todayView->setSelectionMode(QAbstractItemView::NoSelection);
	m_todayView->setVerticalScrollMode(QAbstractItemView::ScrollPerPixel);
	m_todayView->setSpacing(8);
	todayLayout->addWidget(m_todayView);

	connect(m_taskDelegate, &TaskDelegate::toggleRequested, this, &MainWindow::handleTaskToggle);

	rightLayout->addWidget(todayBox);

	auto* examBox = new QGroupBox("Klassenarbeiten", right);
	auto* examLayout = new QVBoxLayout(examBox);
	m_examList = new QListWidget(examBox);
	examLayout->addWidget(m_examList);
	auto* buttonRow = new QHBoxLayout();
	auto* addBtn = new QPushButton("Neu", examBox);
	auto* delBtn = new QPushButton("Löschen", examBox);
	buttonRow->addWidget(addBtn);
	buttonRow->addWidget(delBtn);
	buttonRow->addStretch(1);
	examLayout->addLayout(buttonRow);
	rightLayout->addWidget(examBox);

	auto* mainLayout = new QVBoxLayout(central);
	mainLayout->setContentsMargins(12, 12, 12, 12);
	mainLayout->addWidget(split);
	split->setStretchFactor(0, 2);
	split->setStretchFactor(1, 1);

	connect(addBtn, &QPushButton::clicked, this, &MainWindow::addExam);
	connect(delBtn, &QPushButton::clicked, this, &MainWindow::removeSelectedExam);
	connect(m_search, &QLineEdit::textChanged, this, &MainWindow::onSearchChanged);
	connect(m_onlyOpen, &QCheckBox::toggled, this, &MainWindow::onOnlyOpenToggled);

	m_toasts = new ToastManager(central);
	m_toasts->hide();
}

void MainWindow::applyTheme(bool dark) {
	if (!m_themeManager) return;
	const auto theme = dark ? ThemeManager::Theme::Dark : ThemeManager::Theme::Light;
	m_themeManager->apply(theme);
	if (m_darkModeAction) {
		const QSignalBlocker blocker(m_darkModeAction);
		m_darkModeAction->setChecked(dark);
	}
}

void MainWindow::applyStateToUi() {
	const QSignalBlocker blockSearch(m_search);
	m_search->setText(m_state.searchQuery());

	const QSignalBlocker blockOpen(m_onlyOpen);
	m_onlyOpen->setChecked(m_state.onlyOpen());

	const auto subjects = m_state.subjectFilter();
	for (auto it = m_subjectFilter.begin(); it != m_subjectFilter.end(); ++it) {
		const QSignalBlocker blocker(it.value());
		it.value()->setChecked(subjects.contains(it.key()));
	}
}

void MainWindow::updateFilters() {
	if (m_taskProxy) {
		m_taskProxy->setSubjectFilter(m_state.subjectFilter());
		m_taskProxy->setSearchQuery(m_state.searchQuery());
		m_taskProxy->setOnlyOpen(m_state.onlyOpen());
	}
	if (m_monthView) {
		m_monthView->setFilters(m_state.subjectFilter(), m_state.searchQuery(), m_state.onlyOpen());
	}
}

void MainWindow::refreshToday() {
	renderDayTasks(QDate::currentDate());
}

void MainWindow::refreshDay(const QDate& date) {
	renderDayTasks(date);
	renderExams();
}

void MainWindow::renderDayTasks(const QDate& date) {
	m_currentDay = date;
	const QVector<Task> tasks = m_planner.generateDay(date);
	const int total = tasks.size();
	const int doneCount = std::count_if(tasks.begin(), tasks.end(), [](const Task& task) { return task.done; });

	m_progress->setText(QString("%1/%2 erledigt").arg(doneCount).arg(total));
	m_taskModel->replaceAll(tasks);
	m_taskProxy->invalidate();
}

void MainWindow::renderExams() {
	m_examList->clear();
	auto list = m_planner.exams();
	std::sort(list.begin(), list.end(), [](const Exam& a, const Exam& b) { return a.date < b.date; });

	const auto subjects = m_planner.subjects();
	const auto subjectName = [&](const QString& id) {
		for (const auto& subject : subjects) {
			if (subject.id == id) return subject.name;
		}
		return id;
	};

	if (list.isEmpty()) {
		auto* info = new QListWidgetItem("Keine Klassenarbeiten. Mit „Neu“ hinzufügen.");
		info->setFlags(Qt::NoItemFlags);
		m_examList->addItem(info);
		return;
	}

	for (const auto& exam : list) {
		auto* item = new QListWidgetItem(QString("%1 – %2 (%3)")
											 .arg(subjectName(exam.subjectId))
											 .arg(exam.date.toString(Qt::ISODate))
											 .arg(exam.topics.join(", ")));
		item->setData(Qt::UserRole, exam.id);
		m_examList->addItem(item);
	}
}

void MainWindow::addExam() {
	ExamDialog dlg(m_planner.subjects(), this);
	if (dlg.exec() == QDialog::Accepted) {
		if (m_planner.addOrUpdateExam(dlg.result())) {
			renderExams();
			notify(tr("Klassenarbeit gespeichert"));
		}
	}
}

void MainWindow::removeSelectedExam() {
	auto* item = m_examList->currentItem();
	if (!item) return;
	const QString id = item->data(Qt::UserRole).toString();
	if (id.isEmpty()) return;
	if (QMessageBox::question(this, "Löschen?", "Diese Klassenarbeit wirklich löschen?") == QMessageBox::Yes) {
		if (m_planner.removeExam(id)) {
			renderExams();
			notify(tr("Klassenarbeit entfernt"));
		}
	}
}

void MainWindow::onSearchChanged(const QString& text) {
	if (m_state.setSearchQuery(text.trimmed())) {
		updateFilters();
		saveState();
	}
}

void MainWindow::onOnlyOpenToggled(bool checked) {
	if (m_state.setOnlyOpen(checked)) {
		updateFilters();
		saveState();
	}
}

void MainWindow::onSubjectFilterChanged() {
	QSet<QString> selected;
	for (auto it = m_subjectFilter.constBegin(); it != m_subjectFilter.constEnd(); ++it) {
		if (it.value()->isChecked()) selected.insert(it.key());
	}
	if (m_state.setSubjectFilter(selected)) {
		updateFilters();
		saveState();
	}
}

void MainWindow::onThemeToggled(bool dark) {
	applyTheme(dark);
	if (m_state.setDarkTheme(dark)) {
		saveState();
	}
}

void MainWindow::handleTaskToggle(const QModelIndex& proxyIndex, bool done) {
	if (!proxyIndex.isValid()) return;
	const QModelIndex sourceIndex = m_taskProxy->mapToSource(proxyIndex);
	if (!sourceIndex.isValid()) return;

	const int planIndex = m_taskModel->data(sourceIndex, TaskModel::PlanIndexRole).toInt();
	m_planner.setDone(m_currentDay, planIndex, done);
	m_taskModel->setDone(sourceIndex.row(), done);
	notify(done ? tr("Aufgabe erledigt") : tr("Als offen markiert"));
	renderDayTasks(m_currentDay);
}

void MainWindow::notify(const QString& message) {
	if (m_toasts) {
		m_toasts->showToast(message);
		m_toasts->positionToast();
	}
}

void MainWindow::saveState() {
	m_state.save();
}

void MainWindow::resizeEvent(QResizeEvent* event) {
	QMainWindow::resizeEvent(event);
	if (m_toasts) m_toasts->positionToast();
}

