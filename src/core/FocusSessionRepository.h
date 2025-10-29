#pragma once

#include "FocusSession.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QVector>

class FocusSessionRepository {
public:
    FocusSessionRepository();
    ~FocusSessionRepository();

    bool initialize(const QString& storageDir);

    // Session management
    bool saveSession(const FocusSession& session);
    FocusSession loadActiveSession() const;
    bool clearActiveSession();

    // Session history/log
    bool logCompletedRound(const FocusSession& session);
    QVector<FocusSession> loadHistory(int limit = 100) const;
    
    // Statistics
    int getTotalFocusMinutes() const;
    int getTotalRounds() const;
    QVector<QPair<QDate, int>> getFocusMinutesByDate(const QDate& start, const QDate& end) const;

private:
    QString m_activeSessionPath;
    QString m_historyPath;

    static QJsonObject sessionToJson(const FocusSession& session);
    static FocusSession sessionFromJson(const QJsonObject& obj);
    
    QJsonArray readHistoryArray() const;
    bool writeHistoryArray(const QJsonArray& array) const;
};
