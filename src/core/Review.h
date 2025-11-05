#pragma once

#include <QDate>
#include <QString>

/**
 * @brief Represents a single review record for spaced repetition
 * 
 * This structure implements the SM-2 (SuperMemo 2) algorithm for optimal
 * review intervals. Each review tracks the subject/topic being reviewed,
 * when it was last reviewed, and the calculated parameters for the next review.
 */
struct Review {
    QString id;              // Unique identifier (subjectId_topic or generated)
    QString subjectId;       // Associated subject
    QString topic;           // Specific topic being reviewed
    QDate lastReviewDate;    // When this was last reviewed
    QDate nextReviewDate;    // Calculated next optimal review date
    int repetitionNumber = 0; // Number of successful reviews (n in SM-2)
    double easeFactor = 2.5;  // Ease factor (EF in SM-2), starts at 2.5
    int intervalDays = 0;     // Current interval in days (I in SM-2)
    int quality = 0;          // Last response quality (0-5)
};
