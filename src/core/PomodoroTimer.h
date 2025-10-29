#pragma once

#include "FocusSession.h"
#include "FocusSessionRepository.h"

#include <QObject>
#include <QTimer>

class PomodoroTimer : public QObject {
    Q_OBJECT
    
    Q_PROPERTY(bool isActive READ isActive NOTIFY isActiveChanged)
    Q_PROPERTY(bool isPaused READ isPaused NOTIFY isPausedChanged)
    Q_PROPERTY(int remainingSeconds READ remainingSeconds NOTIFY remainingSecondsChanged)
    Q_PROPERTY(int totalSeconds READ totalSeconds NOTIFY totalSecondsChanged)
    Q_PROPERTY(QString modeString READ modeString NOTIFY modeChanged)
    Q_PROPERTY(int currentRound READ currentRound NOTIFY currentRoundChanged)
    Q_PROPERTY(int totalRounds READ totalRounds NOTIFY totalRoundsChanged)
    Q_PROPERTY(QString presetString READ presetString NOTIFY presetChanged)
    Q_PROPERTY(int totalFocusMinutes READ totalFocusMinutes NOTIFY statisticsChanged)
    Q_PROPERTY(int totalCompletedRounds READ totalCompletedRounds NOTIFY statisticsChanged)

public:
    explicit PomodoroTimer(QObject* parent = nullptr);
    ~PomodoroTimer();

    bool initialize(const QString& storageDir);

    // Getters for Q_PROPERTY
    bool isActive() const { return m_session.isActive; }
    bool isPaused() const { return m_session.isPaused; }
    int remainingSeconds() const { return m_session.remainingSeconds; }
    int totalSeconds() const;
    QString modeString() const;
    int currentRound() const { return m_session.currentRound; }
    int totalRounds() const { return m_session.totalRounds; }
    QString presetString() const;
    int totalFocusMinutes() const;
    int totalCompletedRounds() const;

    // Invokable methods
    Q_INVOKABLE void startSession(const QString& preset, const QString& taskId = QString());
    Q_INVOKABLE void startCustomSession(int workMinutes, int breakMinutes, const QString& taskId = QString());
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void skip();
    Q_INVOKABLE void extend(int minutes);
    Q_INVOKABLE void stop();
    Q_INVOKABLE QVariantList getRecentHistory(int limit = 10) const;
    Q_INVOKABLE QVariantMap getStatistics() const;

signals:
    void isActiveChanged();
    void isPausedChanged();
    void remainingSecondsChanged();
    void totalSecondsChanged();
    void modeChanged();
    void currentRoundChanged();
    void totalRoundsChanged();
    void presetChanged();
    void statisticsChanged();
    void roundCompleted();
    void sessionCompleted();
    void phaseChanged(const QString& newPhase);

private slots:
    void tick();

private:
    FocusSession m_session;
    FocusSessionRepository m_repository;
    QTimer* m_timer;

    void initializeSession(PomodoroPreset preset, const QString& taskId);
    void startPhase(FocusMode mode);
    void completePhase();
    void saveState();
    void loadState();
    void emitAllChanges();
    int getModeDuration(FocusMode mode) const;
};
