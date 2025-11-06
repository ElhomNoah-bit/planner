#pragma once

#include "Review.h"

#include <QHash>
#include <QJsonObject>
#include <QList>
#include <QObject>
#include <QString>

/**
 * @brief Service for managing spaced repetition reviews using SM-2 algorithm
 * 
 * Implements the SuperMemo 2 (SM-2) algorithm for optimal review scheduling.
 * Stores review data in reviews.json and provides methods to:
 * - Add new review items
 * - Record review performance
 * - Calculate next review dates
 * - Query due reviews
 */
class SpacedRepetitionService : public QObject {
    Q_OBJECT
public:
    explicit SpacedRepetitionService(const QString& dataDir = QString(), QObject* parent = nullptr);
    
    /**
     * @brief Initialize or reinitialize with a new data directory
     */
    void setDataDirectory(const QString& dataDir);

    /**
     * @brief Get all reviews
     */
    QList<Review> reviews() const { return m_reviews; }

    /**
     * @brief Get reviews for a specific subject
     */
    QList<Review> reviewsForSubject(const QString& subjectId) const;

    /**
     * @brief Get reviews due on or before a specific date
     */
    QList<Review> dueReviews(const QDate& date = QDate::currentDate()) const;

    /**
     * @brief Get reviews due on a specific date
     */
    QList<Review> reviewsOnDate(const QDate& date) const;

    /**
     * @brief Add a new review item
     * @param subjectId Subject to associate with
     * @param topic Topic to review
     * @return The created review's ID
     */
    QString addReview(const QString& subjectId, const QString& topic);

    /**
     * @brief Record a review performance and calculate next review date
     * @param reviewId Review identifier
     * @param quality Quality of response (0-5):
     *   0 - complete blackout
     *   1 - incorrect response but correct one remembered
     *   2 - incorrect response; correct one seemed easy to recall
     *   3 - correct response recalled with serious difficulty
     *   4 - correct response after hesitation
     *   5 - perfect response
     * @return true if review was successfully recorded
     */
    bool recordReview(const QString& reviewId, int quality);

    /**
     * @brief Remove a review item
     */
    bool removeReview(const QString& reviewId);

    /**
     * @brief Configure initial interval (default: 1 day).
     * Values <= 1 keep new reviews due on the current day for quick onboarding.
     */
    void setInitialInterval(int days);

    /**
     * @brief Configure ease factor adjustment (affects difficulty adaptation)
     */
    void setEaseFactorModifier(double modifier);

Q_SIGNALS:
    void reviewsChanged();

private:
    QString m_dataDir;
    QList<Review> m_reviews;
    int m_initialInterval = 1;      // Initial interval for first review
    double m_easeModifier = 1.0;    // Ease factor adjustment

    void load();
    void save() const;

    /**
     * @brief Calculate next review using SM-2 algorithm
     * @param review Review to update
     * @param quality Response quality (0-5)
     */
    void calculateNextReview(Review& review, int quality);

    /**
     * @brief Generate unique review ID
     */
    QString generateReviewId(const QString& subjectId, const QString& topic) const;
};
