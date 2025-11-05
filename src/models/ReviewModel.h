#pragma once

#include "core/Review.h"

#include <QAbstractListModel>
#include <QList>

/**
 * @brief QML model for spaced repetition reviews
 * 
 * Exposes review data to QML views with roles for all properties.
 * Can be filtered by subject or due date.
 */
class ReviewModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum ReviewRoles {
        IdRole = Qt::UserRole + 1,
        SubjectIdRole,
        TopicRole,
        LastReviewDateRole,
        NextReviewDateRole,
        RepetitionNumberRole,
        EaseFactorRole,
        IntervalDaysRole,
        QualityRole,
        IsDueRole
    };

    explicit ReviewModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setReviews(const QList<Review>& reviews);
    const QList<Review>& reviews() const { return m_reviews; }

private:
    QList<Review> m_reviews;
};
