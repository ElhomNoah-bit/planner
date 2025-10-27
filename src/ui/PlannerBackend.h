#pragma once

#include "AppState.h"
#include "core/PlannerService.h"
#include "models/ExamModel.h"
#include "models/TaskFilterProxy.h"
#include "models/TaskModel.h"

#include <QDate>
#include <QObject>
#include <QColor>
#include <QSet>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class PlannerBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool darkTheme READ darkTheme WRITE setDarkTheme NOTIFY darkThemeChanged)
    Q_PROPERTY(TaskFilterProxy* todayTasks READ todayTasks CONSTANT)
    Q_PROPERTY(ExamModel* exams READ exams CONSTANT)
    Q_PROPERTY(QVariantList subjects READ subjects NOTIFY subjectsChanged)
    Q_PROPERTY(QString selectedDate READ selectedDateIso NOTIFY selectedDateChanged)
    Q_PROPERTY(QString viewMode READ viewMode WRITE setViewMode NOTIFY viewModeChanged)
    Q_PROPERTY(bool onlyOpen READ onlyOpen WRITE setOnlyOpen NOTIFY filtersChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY filtersChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY settingsChanged)
    Q_PROPERTY(QString weekStart READ weekStart WRITE setWeekStart NOTIFY settingsChanged)
    Q_PROPERTY(bool showWeekNumbers READ showWeekNumbers WRITE setShowWeekNumbers NOTIFY settingsChanged)

public:
    explicit PlannerBackend(QObject* parent = nullptr);

    bool darkTheme() const;
    void setDarkTheme(bool dark);

    TaskFilterProxy* todayTasks();
    ExamModel* exams();

    QVariantList subjects() const;

    QString selectedDateIso() const;
    void selectDate(const QDate& date);

    QString viewMode() const { return m_viewMode; }
    void setViewMode(const QString& mode);

    bool onlyOpen() const { return m_state.onlyOpen(); }
    void setOnlyOpen(bool onlyOpen);

    QString searchQuery() const { return m_state.searchQuery(); }
    void setSearchQuery(const QString& query);

    QString language() const { return m_state.language(); }
    void setLanguage(const QString& language);

    QString weekStart() const { return m_state.weekStart(); }
    void setWeekStart(const QString& weekStart);

    bool showWeekNumbers() const { return m_state.weekNumbers(); }
    void setShowWeekNumbers(bool enabled);

    Q_INVOKABLE void selectDateIso(const QString& isoDate);
    Q_INVOKABLE void refreshToday();
    Q_INVOKABLE void toggleTaskDone(int proxyRow, bool done);
    Q_INVOKABLE QVariantList dayEvents(const QString& isoDate) const;
    Q_INVOKABLE QVariantMap daySummary(const QString& isoDate) const;
    Q_INVOKABLE void toggleSubject(const QString& subjectId);
    Q_INVOKABLE void setSubjectFilter(const QStringList& subjectIds);
    Q_INVOKABLE QStringList subjectFilter() const;
    Q_INVOKABLE QVariantMap subjectById(const QString& id) const;
    Q_INVOKABLE QColor subjectColor(const QString& id) const;
    Q_INVOKABLE QVariantList weekEvents(const QString& weekStartIso) const;
    Q_INVOKABLE QVariantList listBuckets() const;
    Q_INVOKABLE void quickAdd(const QString& input);
    Q_INVOKABLE void showToast(const QString& message);

signals:
    void darkThemeChanged();
    void subjectsChanged();
    void selectedDateChanged();
    void tasksChanged();
    void examsChanged();
    void viewModeChanged();
    void filtersChanged();
    void toastRequested(const QString& message);
    void settingsChanged();

private:
    PlannerService m_planner;
    TaskModel m_taskModel;
    TaskFilterProxy m_taskProxy;
    ExamModel m_examModel;
    AppState m_state;

    QList<Subject> m_subjects;
    QDate m_selectedDate;
    QString m_viewMode = QStringLiteral("month");

    void loadSubjects();
    void refreshDayTasks(const QDate& date);
    QVector<Task> filteredTasks(const QVector<Task>& tasks) const;
    QVector<Task> applyFilters(const QVector<Task>& tasks) const;
    QVariantList serializeTasks(const QVector<Task>& tasks) const;
    void reloadExams();
    void updateProxyFilters();
    void notify(const QString& message);
};
