#include "DayCardWidget.h"

#include <QEnterEvent>
#include <QHBoxLayout>
#include <QLabel>
#include <QMouseEvent>
#include <QPainter>
#include <QVBoxLayout>

DayCardWidget::DayCardWidget(QWidget* parent)
    : QFrame(parent), m_dateLabel(new QLabel(this)), m_overflowLabel(new QLabel(this)) {
    setFrameShape(QFrame::NoFrame);
    setAttribute(Qt::WA_Hover, true);
    setCursor(Qt::PointingHandCursor);

    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(12, 10, 12, 12);
    layout->setSpacing(8);

    auto* headerLayout = new QHBoxLayout();
    headerLayout->setContentsMargins(0, 0, 0, 0);
    headerLayout->setSpacing(4);
    headerLayout->addStretch(1);
    m_dateLabel->setObjectName("dayCardDateLabel");
    headerLayout->addWidget(m_dateLabel);
    layout->addLayout(headerLayout);

    m_taskLayout = new QVBoxLayout();
    m_taskLayout->setContentsMargins(0, 0, 0, 0);
    m_taskLayout->setSpacing(6);
    layout->addLayout(m_taskLayout);

    m_overflowLabel->setVisible(false);
    m_overflowLabel->setAlignment(Qt::AlignRight);
    m_overflowLabel->setStyleSheet("font-size: 12px; color: #9CA3AF;");
    layout->addWidget(m_overflowLabel, 0, Qt::AlignRight);

    setSizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
    setMinimumSize(140, 120);
    updateCardStyle();
}

void DayCardWidget::setDate(const QDate& date) {
    m_date = date;
    m_dateLabel->setText(QString::number(date.day()));
    updateDateLabelStyle();
}

void DayCardWidget::setTasks(const QVector<Task>& tasks) {
    m_tasks = tasks;
    rebuildTaskList();
}

void DayCardWidget::setSelected(bool selected) {
    if (m_selected == selected) return;
    m_selected = selected;
    updateCardStyle();
}

void DayCardWidget::setToday(bool today) {
    if (m_isToday == today) return;
    m_isToday = today;
    updateCardStyle();
}

void DayCardWidget::rebuildTaskList() {
    while (auto* child = m_taskLayout->takeAt(0)) {
        if (auto* w = child->widget()) w->deleteLater();
        delete child;
    }

    int displayCount = qMin(3, m_tasks.size());
    for (int i = 0; i < displayCount; ++i) {
        const Task& task = m_tasks.at(i);
        auto* label = new QLabel(this);
        label->setWordWrap(false);
        QString dot = "\u25CF";
        QString text = QString("<span style=\"color:%1;\">%2</span> <span style=\"color:%3;\">%4</span>" )
                            .arg(task.color.name())
                            .arg(dot)
                            .arg("#E6EDF7")
                            .arg(QString("%1 • %2 min").arg(task.title).arg(task.durationMinutes));
        label->setText(text);
        label->setStyleSheet("font-size: 13px; color: #E6EDF7;");
        m_taskLayout->addWidget(label);
    }

    const int remaining = m_tasks.size() - displayCount;
    m_overflowLabel->setVisible(remaining > 0);
    if (remaining > 0) {
        m_overflowLabel->setText(QString("+%1").arg(remaining));
    }
}

void DayCardWidget::enterEvent(QEnterEvent* event) {
    m_hovered = true;
    updateCardStyle();
    QFrame::enterEvent(event);
}

void DayCardWidget::leaveEvent(QEvent* event) {
    m_hovered = false;
    updateCardStyle();
    QFrame::leaveEvent(event);
}

void DayCardWidget::mouseReleaseEvent(QMouseEvent* event) {
    if (event->button() == Qt::LeftButton) {
        emit daySelected(m_date);
    }
    QFrame::mouseReleaseEvent(event);
}

void DayCardWidget::updateCardStyle() {
    QString background = "#141C2C";
    QString border = "rgba(255,255,255,0.08)";

    if (m_hovered) {
        background = "rgba(255,255,255,0.05)";
        border = "rgba(255,255,255,0.18)";
    }

    if (m_isToday) {
        border = "rgba(10,132,255,0.45)";
    }

    if (m_selected) {
        background = "rgba(10,132,255,0.18)";
        border = "rgba(10,132,255,0.9)";
    }

    if (m_selected && m_hovered) {
        background = "rgba(10,132,255,0.24)";
    }

    setStyleSheet(QString("background-color: %1; border: 1px solid %2; border-radius: 14px;")
                      .arg(background, border));
    updateDateLabelStyle();
}

void DayCardWidget::updateDateLabelStyle() {
    QString color = "#9CA3AF";
    QString weight = "400";

    if (m_isToday) {
        color = "#0A84FF";
        weight = "600";
    }

    if (m_selected) {
        color = "#FFFFFF";
        weight = "700";
    }

    m_dateLabel->setStyleSheet(QString("font-size: 13px; color: %1; font-weight: %2;")
                                   .arg(color, weight));
}
