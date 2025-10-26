#pragma once

#include "core/Exam.h"

#include <QAbstractListModel>
#include <QVector>

class ExamModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 50,
        SubjectIdRole,
        DateRole,
        TopicsRole,
        WeightBoostRole
    };

    explicit ExamModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void replaceAll(const QVector<Exam>& exams);
    Exam examAt(int row) const;

private:
    QVector<Exam> m_exams;
};
