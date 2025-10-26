#pragma once

#include "core/Task.h"

#include <QAbstractListModel>
#include <QVector>

class TaskModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        SubjectIdRole,
        TitleRole,
        GoalRole,
        DurationRole,
        DateRole,
        DoneRole,
        IsExamRole,
        ColorRole,
        PlanIndexRole
    };

    explicit TaskModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role) override;
    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    void replaceAll(const QVector<Task>& tasks);
    Task taskAt(int row) const;
    bool setDone(int row, bool done);

private:
    QVector<Task> m_tasks;
};
