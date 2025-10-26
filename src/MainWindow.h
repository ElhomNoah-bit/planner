#pragma once

#include <QMainWindow>
#include <QMap>

#include "core/PlannerService.h"
#include "ui/AppState.h"
#include "ui/theme/ThemeManager.h"

class QListView;
class QListWidget;
class QLineEdit;
class QCheckBox;
class QLabel;
class QPushButton;
class QModelIndex;
class QAction;
class TaskModel;
class TaskFilterProxy;
class TaskDelegate;
class ToastManager;
class MonthView;
class FilterChip;

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent=nullptr);
    ~MainWindow() override;

private slots:
    void refreshToday();
    void refreshDay(const QDate& date);
    void addExam();
    void removeSelectedExam();

private:
    void buildUi();
    void applyTheme(bool dark);
    void applyStateToUi();
    void updateFilters();
    void renderDayTasks(const QDate& date);
    void renderExams();
    void onSearchChanged(const QString& text);
    void onOnlyOpenToggled(bool checked);
    void onSubjectFilterChanged();
    void onThemeToggled(bool dark);
    void handleTaskToggle(const QModelIndex& proxyIndex, bool done);
    void notify(const QString& message);
    void saveState();

    void resizeEvent(QResizeEvent* event) override;

    PlannerService m_planner;
    AppState m_state;
    QDate m_currentDay;

    ThemeManager* m_themeManager = nullptr;
    MonthView* m_monthView = nullptr;
    QListView* m_todayView = nullptr;
    QListWidget* m_examList = nullptr;
    QLineEdit* m_search = nullptr;
    QCheckBox* m_onlyOpen = nullptr;
    QMap<QString, FilterChip*> m_subjectChips;
    QLabel* m_progress = nullptr;
    QAction* m_darkModeAction = nullptr;

    TaskModel* m_taskModel = nullptr;
    TaskFilterProxy* m_taskProxy = nullptr;
    TaskDelegate* m_taskDelegate = nullptr;
    ToastManager* m_toasts = nullptr;
};
