#include "TaskFilterProxy.h"

#include "TaskModel.h"

TaskFilterProxy::TaskFilterProxy(QObject* parent)
    : QSortFilterProxyModel(parent) {
    setDynamicSortFilter(true);
}

void TaskFilterProxy::setSubjectFilter(const QSet<QString>& subjects) {
    if (m_subjects == subjects) return;
    m_subjects = subjects;
    beginFilterChange();
    endFilterChange();
}

void TaskFilterProxy::setSearchQuery(const QString& query) {
    if (m_query == query) return;
    m_query = query;
    beginFilterChange();
    endFilterChange();
}

void TaskFilterProxy::setOnlyOpen(bool onlyOpen) {
    if (m_onlyOpen == onlyOpen) return;
    m_onlyOpen = onlyOpen;
    beginFilterChange();
    endFilterChange();
}

bool TaskFilterProxy::filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const {
    const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    if (!index.isValid()) return false;

    if (!m_subjects.isEmpty()) {
        const QString subjectId = index.data(TaskModel::SubjectIdRole).toString();
        if (!m_subjects.contains(subjectId)) return false;
    }

    if (m_onlyOpen && index.data(TaskModel::DoneRole).toBool()) return false;

    if (!m_query.isEmpty()) {
        const QString title = index.data(TaskModel::TitleRole).toString();
        const QString goal = index.data(TaskModel::GoalRole).toString();
        if (!title.contains(m_query, Qt::CaseInsensitive) && !goal.contains(m_query, Qt::CaseInsensitive)) {
            return false;
        }
    }

    return true;
}
