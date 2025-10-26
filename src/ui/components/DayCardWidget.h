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
    void setSelected(bool selected);
    void setToday(bool today);
    bool isSelected() const { return m_selected; }

    QDate date() const { return m_date; }

signals:
    void daySelected(const QDate& date);

protected:
    void enterEvent(QEnterEvent* event) override;
    void leaveEvent(QEvent* event) override;
    void mouseReleaseEvent(QMouseEvent* event) override;

private:
    void rebuildTaskList();
    void updateCardStyle();
    void updateDateLabelStyle();

    QDate m_date;
    QVector<Task> m_tasks;

    QLabel* m_dateLabel = nullptr;
    QLabel* m_overflowLabel = nullptr;
    QVBoxLayout* m_taskLayout = nullptr;
    bool m_selected = false;
    bool m_isToday = false;
    bool m_hovered = false;
};
