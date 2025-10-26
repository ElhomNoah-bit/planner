#pragma once

#include "core/Task.h"

#include <QDate>
#include <QFrame>

class QLabel;
class QVBoxLayout;

class DayCardWidget : public QFrame {
    Q_OBJECT
public:
    explicit DayCardWidget(QWidget* parent = nullptr);

    void setDate(const QDate& date);
    void setTasks(const QVector<Task>& tasks);

    QDate date() const { return m_date; }

signals:
    void daySelected(const QDate& date);

protected:
    void enterEvent(QEnterEvent* event) override;
    void leaveEvent(QEvent* event) override;
    void mouseReleaseEvent(QMouseEvent* event) override;

private:
    void rebuildTaskList();

    QDate m_date;
    QVector<Task> m_tasks;

    QLabel* m_dateLabel = nullptr;
    QLabel* m_overflowLabel = nullptr;
    QVBoxLayout* m_taskLayout = nullptr;
};
