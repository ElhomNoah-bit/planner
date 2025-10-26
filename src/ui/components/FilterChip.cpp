#include "FilterChip.h"

#include <QPainter>
#include <QStyle>

FilterChip::FilterChip(const QString& label, QWidget* parent)
    : QToolButton(parent) {
    setText(label);
    setCheckable(true);
    setAutoRaise(true);
    setCursor(Qt::PointingHandCursor);
    setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
    setProperty("class", "filter-chip");
}

void FilterChip::setActive(bool active) {
    if (m_active == active) return;
    m_active = active;
    setChecked(active);
    setProperty("active", active);
    style()->unpolish(this);
    style()->polish(this);
    update();
    emit activeChanged(active);
}

void FilterChip::paintEvent(QPaintEvent* event) {
    Q_UNUSED(event);

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);

    const QRect r = rect().adjusted(1, 1, -1, -1);
    QColor border = palette().color(QPalette::Mid);
    QColor background = Qt::transparent;
    QColor textColor = palette().color(QPalette::WindowText);

    if (m_active) {
        background = palette().color(QPalette::Highlight).lighter(140);
        border = palette().color(QPalette::Highlight);
        textColor = palette().color(QPalette::HighlightedText);
    }

    painter.setPen(QPen(border, 1));
    painter.setBrush(background);
    painter.drawRoundedRect(r, 16, 16);

    painter.setPen(textColor);
    painter.setFont(font());
    painter.drawText(r, Qt::AlignCenter, text());
}
