#include "PomodoroTimer.h"

#include <QDebug>
#include <QDateTime>
#include <QUuid>
#include <QVariantList>
#include <QVariantMap>

PomodoroTimer::PomodoroTimer(QObject* parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
{
    m_timer->setInterval(1000); // 1 second tick
    connect(m_timer, &QTimer::timeout, this, &PomodoroTimer::tick);
}

PomodoroTimer::~PomodoroTimer() {
    if (m_session.isActive) {
        saveState();
    }
}

bool PomodoroTimer::initialize(const QString& storageDir) {
    if (!m_repository.initialize(storageDir)) {
        return false;
    }
    
    // Try to restore previous session
    loadState();
    
    return true;
}

int PomodoroTimer::totalSeconds() const {
    return getModeDuration(m_session.mode) * 60;
}

QString PomodoroTimer::modeString() const {
    switch (m_session.mode) {
        case FocusMode::Work:
            return QStringLiteral("work");
        case FocusMode::ShortBreak:
            return QStringLiteral("short_break");
        case FocusMode::LongBreak:
            return QStringLiteral("long_break");
    }
    return QStringLiteral("work");
}

QString PomodoroTimer::presetString() const {
    switch (m_session.preset) {
        case PomodoroPreset::Pomodoro25_5:
            return QStringLiteral("25/5");
        case PomodoroPreset::Extended50_10:
            return QStringLiteral("50/10");
        case PomodoroPreset::Custom:
            return QStringLiteral("custom");
    }
    return QStringLiteral("25/5");
}

int PomodoroTimer::totalFocusMinutes() const {
    return m_repository.getTotalFocusMinutes();
}

int PomodoroTimer::totalCompletedRounds() const {
    return m_repository.getTotalRounds();
}

void PomodoroTimer::startSession(const QString& preset, const QString& taskId) {
    PomodoroPreset presetEnum = PomodoroPreset::Pomodoro25_5;
    
    if (preset == QStringLiteral("50/10")) {
        presetEnum = PomodoroPreset::Extended50_10;
    } else if (preset == QStringLiteral("custom")) {
        presetEnum = PomodoroPreset::Custom;
    }
    
    initializeSession(presetEnum, taskId);
    startPhase(FocusMode::Work);
}

void PomodoroTimer::startCustomSession(int workMinutes, int breakMinutes, const QString& taskId) {
    initializeSession(PomodoroPreset::Custom, taskId);
    m_session.workMinutes = workMinutes;
    m_session.shortBreakMinutes = breakMinutes;
    startPhase(FocusMode::Work);
}

void PomodoroTimer::pause() {
    if (!m_session.isActive || m_session.isPaused) {
        return;
    }
    
    m_session.isPaused = true;
    m_timer->stop();
    saveState();
    
    emit isPausedChanged();
}

void PomodoroTimer::resume() {
    if (!m_session.isActive || !m_session.isPaused) {
        return;
    }
    
    m_session.isPaused = false;
    m_session.lastTickTime = QDateTime::currentDateTime();
    m_timer->start();
    saveState();
    
    emit isPausedChanged();
}

void PomodoroTimer::skip() {
    if (!m_session.isActive) {
        return;
    }
    
    // Complete current phase immediately
    completePhase();
}

void PomodoroTimer::extend(int minutes) {
    if (!m_session.isActive) {
        return;
    }
    
    m_session.remainingSeconds += minutes * 60;
    saveState();
    
    emit remainingSecondsChanged();
}

void PomodoroTimer::stop() {
    if (!m_session.isActive) {
        return;
    }
    
    m_timer->stop();
    m_session.isActive = false;
    m_session.isPaused = false;
    
    m_repository.clearActiveSession();
    
    emitAllChanges();
}

QVariantList PomodoroTimer::getRecentHistory(int limit) const {
    QVector<FocusSession> history = m_repository.loadHistory(limit);
    QVariantList result;
    
    for (const FocusSession& session : history) {
        QVariantMap map;
        map["id"] = session.id;
        map["taskId"] = session.taskId;
        map["mode"] = static_cast<int>(session.mode);
        map["round"] = session.currentRound;
        map["workMinutes"] = session.workMinutes;
        map["startTime"] = session.startTime;
        result.append(map);
    }
    
    return result;
}

QVariantMap PomodoroTimer::getStatistics() const {
    QVariantMap stats;
    stats["totalFocusMinutes"] = totalFocusMinutes();
    stats["totalRounds"] = totalCompletedRounds();
    
    // Get last 7 days statistics
    QDate today = QDate::currentDate();
    QDate weekAgo = today.addDays(-6);
    
    QVector<QPair<QDate, int>> weekData = m_repository.getFocusMinutesByDate(weekAgo, today);
    QVariantList dailyMinutes;
    
    for (const auto& pair : weekData) {
        QVariantMap day;
        day["date"] = pair.first.toString(Qt::ISODate);
        day["minutes"] = pair.second;
        dailyMinutes.append(day);
    }
    
    stats["last7Days"] = dailyMinutes;
    
    return stats;
}

void PomodoroTimer::tick() {
    if (!m_session.isActive || m_session.isPaused) {
        return;
    }
    
    m_session.lastTickTime = QDateTime::currentDateTime();
    
    if (m_session.remainingSeconds > 0) {
        m_session.remainingSeconds--;
        emit remainingSecondsChanged();
        
        // Save state every 10 seconds to handle unexpected termination
        if (m_session.remainingSeconds % 10 == 0) {
            saveState();
        }
    } else {
        completePhase();
    }
}

void PomodoroTimer::initializeSession(PomodoroPreset preset, const QString& taskId) {
    // Stop any existing session
    if (m_session.isActive) {
        stop();
    }
    
    m_session = FocusSession();
    m_session.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    m_session.taskId = taskId;
    m_session.preset = preset;
    m_session.currentRound = 1;
    m_session.totalRounds = 4;
    m_session.startTime = QDateTime::currentDateTime();
    m_session.lastTickTime = m_session.startTime;
    
    // Set durations based on preset
    switch (preset) {
        case PomodoroPreset::Pomodoro25_5:
            m_session.workMinutes = 25;
            m_session.shortBreakMinutes = 5;
            m_session.longBreakMinutes = 15;
            break;
        case PomodoroPreset::Extended50_10:
            m_session.workMinutes = 50;
            m_session.shortBreakMinutes = 10;
            m_session.longBreakMinutes = 20;
            break;
        case PomodoroPreset::Custom:
            // Will be set by caller
            break;
    }
    
    emit presetChanged();
}

void PomodoroTimer::startPhase(FocusMode mode) {
    m_session.mode = mode;
    m_session.remainingSeconds = getModeDuration(mode) * 60;
    m_session.isActive = true;
    m_session.isPaused = false;
    m_session.lastTickTime = QDateTime::currentDateTime();
    
    m_timer->start();
    saveState();
    
    QString phaseStr;
    switch (mode) {
        case FocusMode::Work:
            phaseStr = tr("Fokus");
            break;
        case FocusMode::ShortBreak:
            phaseStr = tr("Kurze Pause");
            break;
        case FocusMode::LongBreak:
            phaseStr = tr("Lange Pause");
            break;
    }
    
    emit phaseChanged(phaseStr);
    emitAllChanges();
}

void PomodoroTimer::completePhase() {
    m_timer->stop();
    
    // Log completed work phase
    if (m_session.mode == FocusMode::Work) {
        m_repository.logCompletedRound(m_session);
        emit roundCompleted();
        emit statisticsChanged();
    }
    
    // Determine next phase
    if (m_session.mode == FocusMode::Work) {
        // After work, take a break
        if (m_session.currentRound >= m_session.totalRounds) {
            // Long break after completing all rounds
            startPhase(FocusMode::LongBreak);
        } else {
            // Short break
            startPhase(FocusMode::ShortBreak);
        }
    } else {
        // After break, back to work
        if (m_session.mode == FocusMode::LongBreak) {
            // Reset round counter after long break
            m_session.currentRound = 1;
            emit currentRoundChanged();
        } else {
            // Increment round after short break
            m_session.currentRound++;
            emit currentRoundChanged();
        }
        
        if (m_session.currentRound <= m_session.totalRounds) {
            startPhase(FocusMode::Work);
        } else {
            // Session completed
            m_session.isActive = false;
            m_repository.clearActiveSession();
            emit sessionCompleted();
            emitAllChanges();
        }
    }
}

void PomodoroTimer::saveState() {
    if (m_session.isActive) {
        m_repository.saveSession(m_session);
    }
}

void PomodoroTimer::loadState() {
    FocusSession saved = m_repository.loadActiveSession();
    
    if (!saved.isActive || saved.id.isEmpty()) {
        return;
    }
    
    // Check if session is still valid (not too old)
    if (saved.lastTickTime.isValid()) {
        qint64 secondsElapsed = saved.lastTickTime.secsTo(QDateTime::currentDateTime());
        
        // If more than 1 hour has passed, discard the session
        if (secondsElapsed > 3600) {
            m_repository.clearActiveSession();
            return;
        }
        
        // Adjust remaining time based on elapsed time if not paused
        if (!saved.isPaused && secondsElapsed > 0) {
            saved.remainingSeconds = qMax(0, saved.remainingSeconds - static_cast<int>(secondsElapsed));
        }
    }
    
    m_session = saved;
    
    // Resume timer if session was active and not paused
    if (m_session.isActive && !m_session.isPaused && m_session.remainingSeconds > 0) {
        m_session.lastTickTime = QDateTime::currentDateTime();
        m_timer->start();
    }
    
    emitAllChanges();
}

void PomodoroTimer::emitAllChanges() {
    emit isActiveChanged();
    emit isPausedChanged();
    emit remainingSecondsChanged();
    emit totalSecondsChanged();
    emit modeChanged();
    emit currentRoundChanged();
    emit totalRoundsChanged();
}

int PomodoroTimer::getModeDuration(FocusMode mode) const {
    switch (mode) {
        case FocusMode::Work:
            return m_session.workMinutes;
        case FocusMode::ShortBreak:
            return m_session.shortBreakMinutes;
        case FocusMode::LongBreak:
            return m_session.longBreakMinutes;
    }
    return 25;
}
