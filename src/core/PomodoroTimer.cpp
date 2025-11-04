#include "PomodoroTimer.h"

PomodoroTimer::PomodoroTimer(QObject* parent)
    : QObject(parent) {
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &PomodoroTimer::handleTimeout);
}

void PomodoroTimer::setFocusMinutes(int minutes) {
    if (minutes > 0) {
        m_focusMinutes = minutes;
    }
}

void PomodoroTimer::setBreakMinutes(int minutes) {
    if (minutes > 0) {
        m_breakMinutes = minutes;
    }
}

void PomodoroTimer::setLongBreakMinutes(int minutes) {
    if (minutes > 0) {
        m_longBreakMinutes = minutes;
    }
}

void PomodoroTimer::setCyclesBeforeLongBreak(int cycles) {
    if (cycles > 0) {
        m_cyclesBeforeLongBreak = cycles;
    }
}

void PomodoroTimer::start() {
    if (m_phase == Phase::Idle) {
        m_completedCycles = 0;
    }
    beginPhase(Phase::Focus);
}

void PomodoroTimer::stop() {
    if (!m_running && m_phase == Phase::Idle) {
        return;
    }
    m_timer.stop();
    m_running = false;
    m_phase = Phase::Idle;
    m_remainingSeconds = 0;
    emit runningChanged(false);
    emit phaseChanged(m_phase);
}

void PomodoroTimer::skipPhase() {
    switch (m_phase) {
    case Phase::Focus:
        beginPhase(Phase::ShortBreak, true);
        break;
    case Phase::ShortBreak:
    case Phase::LongBreak:
        beginPhase(Phase::Focus);
        break;
    case Phase::Idle:
    default:
        break;
    }
}

void PomodoroTimer::beginPhase(Phase nextPhase, bool preserveCompletion) {
    m_phase = nextPhase;
    m_remainingSeconds = phaseLengthSeconds(nextPhase);
    if (!preserveCompletion && nextPhase == Phase::Focus) {
        // Starting a new focus session resets the timer completely
        m_timer.stop();
    }
    if (m_remainingSeconds <= 0) {
        m_remainingSeconds = 60;
    }
    m_running = true;
    emit runningChanged(true);
    emit phaseChanged(m_phase);
    m_timer.start();
    emit tick();
}

int PomodoroTimer::phaseLengthSeconds(Phase phase) const {
    switch (phase) {
    case Phase::Focus:
        return m_focusMinutes * 60;
    case Phase::LongBreak:
        return m_longBreakMinutes * 60;
    case Phase::ShortBreak:
        return m_breakMinutes * 60;
    case Phase::Idle:
    default:
        break;
    }
    return 0;
}

void PomodoroTimer::handleTimeout() {
    if (!m_running) {
        return;
    }
    if (m_remainingSeconds > 0) {
        m_remainingSeconds -= 1;
    }
    emit tick();

    if (m_remainingSeconds > 0) {
        return;
    }

    if (m_phase == Phase::Focus) {
        m_completedCycles += 1;
        emit cycleCompleted(m_completedCycles);
        const bool longBreak = m_cyclesBeforeLongBreak > 0 && (m_completedCycles % m_cyclesBeforeLongBreak) == 0;
        beginPhase(longBreak ? Phase::LongBreak : Phase::ShortBreak, true);
        return;
    }

    if (m_phase == Phase::ShortBreak || m_phase == Phase::LongBreak) {
        beginPhase(Phase::Focus);
        return;
    }

    stop();
}
