#pragma once

#include <QDateTime>
#include <QString>

struct FocusSession {
    QString id;
    QString taskId;
    QDateTime start;
    QDateTime end;
    int durationSeconds = 0;  // Total duration in seconds
    bool completed = false;   // Whether session ended normally or was interrupted
};
