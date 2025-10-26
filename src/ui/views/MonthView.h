#pragma once

#include "core/PlannerService.h"

#include <QDate>
#include <QList>
#include <QSet>
#include <QVector>
#include <QWidget>

class DayCardWidget;
class QGridLayout;

class MonthView : public QWidget {
    Q_OBJECT
public:
    explicit MonthView(QWidget* parent = nullptr);

    void setPlanner(PlannerService* planner);
    void setMonth(const QDate& month);
    void setSelectedDate(const QDate& date);
    void setFilters(const QSet<QString>& subjects, const QString& query, bool onlyOpen);
    void refresh();

signals:
    void daySelected(const QDate& date);

private:
    void rebuildGrid();
    QVector<Task> filteredTasksFor(const QDate& date) const;
    void handleDayClicked(const QDate& date);

    PlannerService* m_planner = nullptr;
    QDate m_month;
    QDate m_selectedDate;
    QSet<QString> m_subjects;
    QString m_query;
    bool m_onlyOpen = false;

    QGridLayout* m_grid = nullptr;
    QList<DayCardWidget*> m_cards;
};
