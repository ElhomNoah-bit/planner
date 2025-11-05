#pragma once

#include <QColor>
#include <QDate>
#include <QString>
#include <QStringList>

#include "Priority.h"

struct Task {
    QString id;
    QString subjectId;
    QString title;
    QString goal;
    int durationMinutes = 0;
    QDate date;
    bool done = false;
    bool isExam = false;
    QColor color;
    QString seriesId;
    int planIndex = -1;
    Priority priority = Priority::Medium;
    
    // Spaced repetition properties
    bool isReview = false;     // True if this is a review task
    QString reviewId;          // Associated review ID if isReview is true
};
