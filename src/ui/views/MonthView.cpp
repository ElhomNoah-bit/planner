#include "MonthView.h"

#include "ui/components/DayCardWidget.h"

#include <QGridLayout>
#include <QSizePolicy>

#include <algorithm>

MonthView::MonthView(QWidget* parent)
    : QWidget(parent), m_grid(new QGridLayout(this)) {
    m_grid->setSpacing(12);
    m_grid->setContentsMargins(0, 0, 0, 0);
}

void MonthView::setPlanner(PlannerService* planner) {
    m_planner = planner;
    refresh();
}

void MonthView::setMonth(const QDate& month) {
    if (!month.isValid()) return;
    const QDate firstDay(month.year(), month.month(), 1);
    if (m_month == firstDay) return;
    m_month = firstDay;
    refresh();
}

void MonthView::setSelectedDate(const QDate& date) {
    if (m_selectedDate == date) return;
    m_selectedDate = date;
    if (!date.isValid()) {
        refresh();
        return;
    }

    if (m_month.isValid() && m_month.year() == date.year() && m_month.month() == date.month()) {
        refresh();
    }
}

void MonthView::setFilters(const QSet<QString>& subjects, const QString& query, bool onlyOpen) {
    m_subjects = subjects;
    m_query = query;
    m_onlyOpen = onlyOpen;
    refresh();
}

void MonthView::refresh() {
    if (!m_planner || !m_month.isValid()) return;
    rebuildGrid();
}

void MonthView::rebuildGrid() {
    while (QLayoutItem* item = m_grid->takeAt(0)) {
        if (QWidget* widget = item->widget()) widget->deleteLater();
        delete item;
    }
    m_cards.clear();

    QDate first = QDate(m_month.year(), m_month.month(), 1);
    int startColumn = first.dayOfWeek() % 7; // make Monday=0
    int daysInMonth = m_month.daysInMonth();

    int row = 0;
    int column = startColumn;

    for (int day = 1; day <= daysInMonth; ++day) {
        if (column >= 7) {
            column = 0;
            ++row;
        }

        DayCardWidget* card = new DayCardWidget(this);
        const QDate date(m_month.year(), m_month.month(), day);
        card->setDate(date);
        const QVector<Task> tasks = filteredTasksFor(date);
        card->setTasks(tasks);
        card->setToday(date == QDate::currentDate());
        card->setSelected(m_selectedDate.isValid() && m_selectedDate == date);
        connect(card, &DayCardWidget::daySelected, this, &MonthView::handleDayClicked);

        m_grid->addWidget(card, row, column);
        m_cards.append(card);
        ++column;
    }

    // fill remaining cells to keep grid aligned
    while (column < 7) {
        auto* spacer = new QWidget(this);
        spacer->setSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::Expanding);
        spacer->setStyleSheet("background: transparent; border: none;");
        m_grid->addWidget(spacer, row, column);
        ++column;
    }
}

QVector<Task> MonthView::filteredTasksFor(const QDate& date) const {
    QVector<Task> tasks = m_planner->generateDay(date);

    if (!m_subjects.isEmpty()) {
        tasks.erase(std::remove_if(tasks.begin(), tasks.end(), [&](const Task& task) {
            return !m_subjects.contains(task.subjectId);
        }), tasks.end());
    }

    if (m_onlyOpen) {
        tasks.erase(std::remove_if(tasks.begin(), tasks.end(), [](const Task& task) {
            return task.done;
        }), tasks.end());
    }

    if (!m_query.isEmpty()) {
        tasks.erase(std::remove_if(tasks.begin(), tasks.end(), [&](const Task& task) {
            return !task.title.contains(m_query, Qt::CaseInsensitive) &&
                   !task.goal.contains(m_query, Qt::CaseInsensitive);
        }), tasks.end());
    }

    return tasks;
}

void MonthView::handleDayClicked(const QDate& date) {
    setSelectedDate(date);
    emit daySelected(date);
}
