#include "TaskModel.h"

#include <QVariant>

TaskModel::TaskModel(QObject* parent) : QAbstractListModel(parent) {}

int TaskModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_tasks.size();
}

QVariant TaskModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tasks.size()) return {};

    const Task& task = m_tasks.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case TitleRole:
        return task.title;
    case GoalRole:
        return task.goal;
    case DurationRole:
        return task.durationMinutes;
    case SubjectIdRole:
        return task.subjectId;
    case DateRole:
        return task.date;
    case DoneRole:
        return task.done;
    case IsExamRole:
        return task.isExam;
    case ColorRole:
        return task.color;
    case IdRole:
        return task.id;
    case PlanIndexRole:
        return task.planIndex;
    case PriorityRole:
        return static_cast<int>(task.priority);
    case Qt::CheckStateRole:
        return task.done ? Qt::Checked : Qt::Unchecked;
    default:
        return {};
    }
}

bool TaskModel::setData(const QModelIndex& index, const QVariant& value, int role) {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tasks.size()) return false;

    Task& task = m_tasks[index.row()];
    if (role == DoneRole) {
        bool done = value.toBool();
        if (task.done == done) return false;
        task.done = done;
        emit dataChanged(index, index, {DoneRole, Qt::CheckStateRole});
        return true;
    }
    if (role == Qt::CheckStateRole) {
        const bool done = value.toInt() == Qt::Checked;
        if (task.done == done) return false;
        task.done = done;
        emit dataChanged(index, index, {DoneRole, Qt::CheckStateRole});
        return true;
    }
    return false;
}

QHash<int, QByteArray> TaskModel::roleNames() const {
    return {
        {IdRole, "id"},
        {SubjectIdRole, "subjectId"},
        {TitleRole, "title"},
        {GoalRole, "goal"},
        {DurationRole, "duration"},
        {DateRole, "date"},
        {DoneRole, "done"},
        {IsExamRole, "isExam"},
        {ColorRole, "color"},
        {PlanIndexRole, "planIndex"},
        {PriorityRole, "priority"}
    };
}

Qt::ItemFlags TaskModel::flags(const QModelIndex& index) const {
    if (!index.isValid()) return Qt::NoItemFlags;
    return QAbstractListModel::flags(index) | Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsUserCheckable;
}

void TaskModel::replaceAll(const QVector<Task>& tasks) {
    beginResetModel();
    m_tasks = tasks;
    endResetModel();
}

Task TaskModel::taskAt(int row) const {
    if (row < 0 || row >= m_tasks.size()) return Task{};
    return m_tasks.at(row);
}

bool TaskModel::setDone(int row, bool done) {
    return setData(index(row, 0), done, DoneRole);
}
