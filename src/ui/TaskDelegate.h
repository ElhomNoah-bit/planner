#pragma once

#include <QStyledItemDelegate>

class TaskDelegate : public QStyledItemDelegate {
    Q_OBJECT
public:
    explicit TaskDelegate(QObject* parent = nullptr);

    QSize sizeHint(const QStyleOptionViewItem& option, const QModelIndex& index) const override;
    void paint(QPainter* painter, const QStyleOptionViewItem& option, const QModelIndex& index) const override;
    bool editorEvent(QEvent* event, QAbstractItemModel* model, const QStyleOptionViewItem& option,
                     const QModelIndex& index) override;

Q_SIGNALS:
    void toggleRequested(const QModelIndex& index, bool done) const;

private:
    QRect checkboxRect(const QRect& cardRect) const;
};
