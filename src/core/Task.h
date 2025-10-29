#pragma once

#include <QColor>
#include <QDate>
#include <QString>
#include <QStringList>

enum class Priority {
    Low = 0,
    Medium = 1,
    High = 2
};

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
};
