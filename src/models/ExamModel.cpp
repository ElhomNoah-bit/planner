#include "ExamModel.h"

#include <QVariant>

ExamModel::ExamModel(QObject* parent) : QAbstractListModel(parent) {}

int ExamModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_exams.size();
}

QVariant ExamModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_exams.size()) return {};

    const Exam& exam = m_exams.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case SubjectIdRole:
        return exam.subjectId;
    case DateRole:
        return exam.date;
    case TopicsRole:
        return QVariant::fromValue(exam.topics);
    case WeightBoostRole:
        return exam.weightBoost;
    case IdRole:
        return exam.id;
    default:
        return {};
    }
}

QHash<int, QByteArray> ExamModel::roleNames() const {
    return {
        {IdRole, "id"},
        {SubjectIdRole, "subjectId"},
        {DateRole, "date"},
        {TopicsRole, "topics"},
        {WeightBoostRole, "weightBoost"}
    };
}

void ExamModel::replaceAll(const QVector<Exam>& exams) {
    beginResetModel();
    m_exams = exams;
    endResetModel();
}

Exam ExamModel::examAt(int row) const {
    if (row < 0 || row >= m_exams.size()) return Exam{};
    return m_exams.at(row);
}
