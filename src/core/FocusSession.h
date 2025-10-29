#pragma once

#include <QDateTime>
#include <QString>

enum class FocusMode {
    Work = 0,
    ShortBreak = 1,
    LongBreak = 2
};

enum class PomodoroPreset {
    Pomodoro25_5 = 0,   // 25 min work, 5 min break
    Extended50_10 = 1,   // 50 min work, 10 min break
    Custom = 2           // User-defined duration
};

struct FocusSession {
    QString id;
    QString taskId;              // Optional: linked task ID
    FocusMode mode = FocusMode::Work;
    PomodoroPreset preset = PomodoroPreset::Pomodoro25_5;
    int currentRound = 1;        // Current Pomodoro round (1-indexed)
    int totalRounds = 4;         // Total rounds before long break
    int workMinutes = 25;        // Work duration in minutes
    int shortBreakMinutes = 5;   // Short break duration
    int longBreakMinutes = 15;   // Long break duration
    int remainingSeconds = 0;    // Remaining seconds in current phase
    bool isPaused = false;
    QDateTime startTime;         // When this session started
    QDateTime lastTickTime;      // Last tick timestamp for recovery
    bool isActive = false;       // Whether session is currently running
};
