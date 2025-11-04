#pragma once

#include "FocusSession.h"

#include <QDate>
#include <QDateTime>
#include <QVector>
#include <QString>

class FocusSessionRepository {
public:
    FocusSessionRepository();

    void setStorageDirectory(const QString& directory);

    bool hasActiveSession() const;
    QDateTime activeSessionStart() const;
    bool startSession(const QDateTime& start);
    FocusSession finishSession(const QDateTime& end, bool completed);
    void cancelActiveSession();

    QVector<FocusSession> sessions() const;
    int currentStreak(const QDate& today) const;

private:
    QString m_storageDir;
    mutable QVector<FocusSession> m_cache;
    mutable bool m_loaded = false;
    mutable bool m_stateLoaded = false;
    mutable QDateTime m_activeStart;

    QString sessionsPath() const;
    QString statePath() const;

    void ensureLoaded() const;
    void ensureStateLoaded() const;
    void saveSessions(const QVector<FocusSession>& sessions) const;
    void saveState() const;
};
