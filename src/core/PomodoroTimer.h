#pragma once

#include <QObject>
#include <QTimer>

class PomodoroTimer : public QObject {
    Q_OBJECT
public:
    enum class Phase {
        Idle,
        Focus,
        ShortBreak,
        LongBreak
    };
    Q_ENUM(Phase)

    explicit PomodoroTimer(QObject* parent = nullptr);

    bool isRunning() const { return m_running; }
    Phase phase() const { return m_phase; }
    int remainingSeconds() const { return m_remainingSeconds; }
    int focusMinutes() const { return m_focusMinutes; }
    int breakMinutes() const { return m_breakMinutes; }
    int longBreakMinutes() const { return m_longBreakMinutes; }
    int cyclesBeforeLongBreak() const { return m_cyclesBeforeLongBreak; }
    int completedCycles() const { return m_completedCycles; }

    void setFocusMinutes(int minutes);
    void setBreakMinutes(int minutes);
    void setLongBreakMinutes(int minutes);
    void setCyclesBeforeLongBreak(int cycles);

public slots:
    void start();
    void stop();
    void skipPhase();

signals:
    void tick();
    void phaseChanged(PomodoroTimer::Phase phase);
    void runningChanged(bool running);
    void cycleCompleted(int totalCycles);

private:
    QTimer m_timer;
    Phase m_phase = Phase::Idle;
    bool m_running = false;
    int m_remainingSeconds = 0;
    int m_focusMinutes = 25;
    int m_breakMinutes = 5;
    int m_longBreakMinutes = 15;
    int m_cyclesBeforeLongBreak = 4;
    int m_completedCycles = 0;

    void beginPhase(Phase nextPhase, bool preserveCompletion = false);
    int phaseLengthSeconds(Phase phase) const;
    void handleTimeout();
};
