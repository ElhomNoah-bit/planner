#include "TaskDelegate.h"

#include "models/TaskModel.h"

#include <QApplication>
#include <QMouseEvent>
#include <QPainter>
#include <QStyle>
#include <QStyleOptionButton>

namespace {
QString metaText(const QModelIndex& index) {
    const int duration = index.data(TaskModel::DurationRole).toInt();
    const QString goal = index.data(TaskModel::GoalRole).toString();
    return QString::number(duration) + " min • " + goal;
}
}

TaskDelegate::TaskDelegate(QObject* parent)
    : QStyledItemDelegate(parent) {}

QSize TaskDelegate::sizeHint(const QStyleOptionViewItem& option, const QModelIndex& index) const {
    Q_UNUSED(index);
    const int height = qMax(72, option.fontMetrics.height() * 3);
    return QSize(option.rect.width(), height);
}

void TaskDelegate::paint(QPainter* painter, const QStyleOptionViewItem& option, const QModelIndex& index) const {
    QStyleOptionViewItem opt(option);
    initStyleOption(&opt, index);

    painter->save();
    painter->setRenderHint(QPainter::Antialiasing);

    QRect cardRect = option.rect.adjusted(6, 4, -6, -4);
    const bool selected = option.state.testFlag(QStyle::State_Selected);
    QColor background = selected ? option.palette.color(QPalette::Highlight)
                                 : option.palette.color(QPalette::Base);
    painter->setBrush(background);
    painter->setPen(Qt::NoPen);
    painter->drawRoundedRect(cardRect, 12, 12);

    QColor stripColor = index.data(TaskModel::ColorRole).value<QColor>();
    if (!stripColor.isValid()) stripColor = option.palette.color(QPalette::Highlight);
    QRect stripRect = cardRect;
    stripRect.setWidth(4);
    painter->setBrush(stripColor);
    painter->drawRoundedRect(stripRect, 12, 12);

    QRect internalRect = cardRect.adjusted(16, 10, -16, -12);
    QRect cbRect = checkboxRect(cardRect);

    QStyleOptionButton cbOpt;
    cbOpt.rect = cbRect;
    cbOpt.state = QStyle::State_Enabled | (index.data(TaskModel::DoneRole).toBool() ? QStyle::State_On : QStyle::State_Off);
    QApplication::style()->drawControl(QStyle::CE_CheckBox, &cbOpt, painter);

    const bool done = index.data(TaskModel::DoneRole).toBool();
    QFont titleFont = option.font;
    titleFont.setPointSize(16);
    titleFont.setBold(true);
    titleFont.setStrikeOut(done);

    QFont metaFont = option.font;
    metaFont.setPointSize(12);

    QColor titleColor = done ? option.palette.color(QPalette::Mid) : option.palette.color(QPalette::Text);
    QColor metaColor = option.palette.color(QPalette::PlaceholderText);

    QRect textRect = internalRect;
    textRect.setLeft(cbRect.right() + 12);

    const QString title = QFontMetrics(titleFont).elidedText(index.data(TaskModel::TitleRole).toString(), Qt::ElideRight, textRect.width());
    painter->setPen(titleColor);
    painter->setFont(titleFont);
    painter->drawText(textRect, Qt::TextSingleLine | Qt::AlignVCenter, title);

    painter->setPen(metaColor);
    painter->setFont(metaFont);
    const QFontMetrics metaMetrics(metaFont);
    QRect metaRect = textRect.adjusted(0, metaMetrics.height() + 6, 0, 0);
    const QString meta = metaMetrics.elidedText(metaText(index), Qt::ElideRight, metaRect.width());
    painter->drawText(metaRect, Qt::TextSingleLine | Qt::AlignVCenter, meta);

    painter->restore();
}

bool TaskDelegate::editorEvent(QEvent* event, QAbstractItemModel* model, const QStyleOptionViewItem& option,
                               const QModelIndex& index) {
    if (!index.isValid()) return false;
    if (event->type() == QEvent::MouseButtonRelease) {
        const auto* mouseEvent = static_cast<QMouseEvent*>(event);
        QRect cardRect = option.rect.adjusted(6, 4, -6, -4);
        if (checkboxRect(cardRect).contains(mouseEvent->pos())) {
            const bool done = index.data(TaskModel::DoneRole).toBool();
            const bool newState = !done;
            model->setData(index, newState, Qt::CheckStateRole);
            emit toggleRequested(index, newState);
            return true;
        }
    }
    return QStyledItemDelegate::editorEvent(event, model, option, index);
}

QRect TaskDelegate::checkboxRect(const QRect& cardRect) const {
    const int size = 20;
    return QRect(cardRect.left() + 12, cardRect.center().y() - size / 2, size, size);
}
