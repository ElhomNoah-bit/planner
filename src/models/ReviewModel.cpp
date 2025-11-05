#include "ReviewModel.h"

#include <QDate>

ReviewModel::ReviewModel(QObject* parent) : QAbstractListModel(parent) {}

int ReviewModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_reviews.size();
}

QVariant ReviewModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_reviews.size()) {
        return QVariant();
    }

    const Review& review = m_reviews[index.row()];
    const QDate today = QDate::currentDate();

    switch (role) {
    case IdRole:
        return review.id;
    case SubjectIdRole:
        return review.subjectId;
    case TopicRole:
        return review.topic;
    case LastReviewDateRole:
        return review.lastReviewDate.toString(Qt::ISODate);
    case NextReviewDateRole:
        return review.nextReviewDate.toString(Qt::ISODate);
    case RepetitionNumberRole:
        return review.repetitionNumber;
    case EaseFactorRole:
        return review.easeFactor;
    case IntervalDaysRole:
        return review.intervalDays;
    case QualityRole:
        return review.quality;
    case IsDueRole:
        return review.nextReviewDate <= today;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ReviewModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "reviewId";
    roles[SubjectIdRole] = "subjectId";
    roles[TopicRole] = "topic";
    roles[LastReviewDateRole] = "lastReviewDate";
    roles[NextReviewDateRole] = "nextReviewDate";
    roles[RepetitionNumberRole] = "repetitionNumber";
    roles[EaseFactorRole] = "easeFactor";
    roles[IntervalDaysRole] = "intervalDays";
    roles[QualityRole] = "quality";
    roles[IsDueRole] = "isDue";
    return roles;
}

void ReviewModel::setReviews(const QList<Review>& reviews) {
    beginResetModel();
    m_reviews = reviews;
    endResetModel();
}
