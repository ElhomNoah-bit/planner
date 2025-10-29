#include "FocusSessionRepository.h"

#include <QDate>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUuid>

FocusSessionRepository::FocusSessionRepository() = default;
FocusSessionRepository::~FocusSessionRepository() = default;

bool FocusSessionRepository::initialize(const QString& storageDir) {
    QDir dir(storageDir);
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "Failed to create storage directory:" << storageDir;
            return false;
        }
    }

    m_activeSessionPath = dir.filePath("focus_session_active.json");
    m_historyPath = dir.filePath("focus_session_history.json");

    // Create history file if it doesn't exist
    if (!QFile::exists(m_historyPath)) {
        QJsonArray emptyArray;
        QJsonDocument doc(emptyArray);
        QFile file(m_historyPath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(doc.toJson());
            file.close();
        }
    }

    return true;
}

bool FocusSessionRepository::saveSession(const FocusSession& session) {
    QJsonObject obj = sessionToJson(session);
    QJsonDocument doc(obj);

    QFile file(m_activeSessionPath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open active session file for writing:" << m_activeSessionPath;
        return false;
    }

    file.write(doc.toJson());
    file.close();
    return true;
}

FocusSession FocusSessionRepository::loadActiveSession() const {
    QFile file(m_activeSessionPath);
    if (!file.exists()) {
        return FocusSession();
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open active session file for reading:" << m_activeSessionPath;
        return FocusSession();
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        return FocusSession();
    }

    return sessionFromJson(doc.object());
}

bool FocusSessionRepository::clearActiveSession() {
    QFile file(m_activeSessionPath);
    if (file.exists()) {
        return file.remove();
    }
    return true;
}

bool FocusSessionRepository::logCompletedRound(const FocusSession& session) {
    QJsonArray history = readHistoryArray();
    
    QJsonObject logEntry = sessionToJson(session);
    logEntry["completedAt"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    history.append(logEntry);
    
    // Keep only last 1000 entries to avoid unbounded growth
    if (history.size() > 1000) {
        history = history.mid(history.size() - 1000);
    }
    
    return writeHistoryArray(history);
}

QVector<FocusSession> FocusSessionRepository::loadHistory(int limit) const {
    QJsonArray history = readHistoryArray();
    QVector<FocusSession> sessions;
    
    int start = qMax(0, history.size() - limit);
    for (int i = start; i < history.size(); ++i) {
        if (history[i].isObject()) {
            sessions.append(sessionFromJson(history[i].toObject()));
        }
    }
    
    return sessions;
}

int FocusSessionRepository::getTotalFocusMinutes() const {
    QJsonArray history = readHistoryArray();
    int totalMinutes = 0;
    
    for (const QJsonValue& val : history) {
        if (val.isObject()) {
            QJsonObject obj = val.toObject();
            if (obj["mode"].toInt() == static_cast<int>(FocusMode::Work)) {
                // Calculate actual work time
                int workMinutes = obj["workMinutes"].toInt(25);
                int remainingSeconds = obj["remainingSeconds"].toInt(0);
                int completedSeconds = (workMinutes * 60) - remainingSeconds;
                totalMinutes += completedSeconds / 60;
            }
        }
    }
    
    return totalMinutes;
}

int FocusSessionRepository::getTotalRounds() const {
    QJsonArray history = readHistoryArray();
    int totalRounds = 0;
    
    for (const QJsonValue& val : history) {
        if (val.isObject()) {
            QJsonObject obj = val.toObject();
            if (obj["mode"].toInt() == static_cast<int>(FocusMode::Work)) {
                totalRounds++;
            }
        }
    }
    
    return totalRounds;
}

QVector<QPair<QDate, int>> FocusSessionRepository::getFocusMinutesByDate(const QDate& start, const QDate& end) const {
    QJsonArray history = readHistoryArray();
    QMap<QDate, int> minutesByDate;
    
    for (const QJsonValue& val : history) {
        if (val.isObject()) {
            QJsonObject obj = val.toObject();
            if (obj["mode"].toInt() == static_cast<int>(FocusMode::Work)) {
                QString completedAtStr = obj["completedAt"].toString();
                if (!completedAtStr.isEmpty()) {
                    QDateTime completedAt = QDateTime::fromString(completedAtStr, Qt::ISODate);
                    QDate date = completedAt.date();
                    
                    if (date >= start && date <= end) {
                        int workMinutes = obj["workMinutes"].toInt(25);
                        int remainingSeconds = obj["remainingSeconds"].toInt(0);
                        int completedSeconds = (workMinutes * 60) - remainingSeconds;
                        minutesByDate[date] += completedSeconds / 60;
                    }
                }
            }
        }
    }
    
    QVector<QPair<QDate, int>> result;
    for (auto it = minutesByDate.begin(); it != minutesByDate.end(); ++it) {
        result.append(qMakePair(it.key(), it.value()));
    }
    
    return result;
}

QJsonObject FocusSessionRepository::sessionToJson(const FocusSession& session) {
    QJsonObject obj;
    obj["id"] = session.id;
    obj["taskId"] = session.taskId;
    obj["mode"] = static_cast<int>(session.mode);
    obj["preset"] = static_cast<int>(session.preset);
    obj["currentRound"] = session.currentRound;
    obj["totalRounds"] = session.totalRounds;
    obj["workMinutes"] = session.workMinutes;
    obj["shortBreakMinutes"] = session.shortBreakMinutes;
    obj["longBreakMinutes"] = session.longBreakMinutes;
    obj["remainingSeconds"] = session.remainingSeconds;
    obj["isPaused"] = session.isPaused;
    obj["isActive"] = session.isActive;
    
    if (session.startTime.isValid()) {
        obj["startTime"] = session.startTime.toString(Qt::ISODate);
    }
    if (session.lastTickTime.isValid()) {
        obj["lastTickTime"] = session.lastTickTime.toString(Qt::ISODate);
    }
    
    return obj;
}

FocusSession FocusSessionRepository::sessionFromJson(const QJsonObject& obj) {
    FocusSession session;
    session.id = obj["id"].toString();
    session.taskId = obj["taskId"].toString();
    session.mode = static_cast<FocusMode>(obj["mode"].toInt(0));
    session.preset = static_cast<PomodoroPreset>(obj["preset"].toInt(0));
    session.currentRound = obj["currentRound"].toInt(1);
    session.totalRounds = obj["totalRounds"].toInt(4);
    session.workMinutes = obj["workMinutes"].toInt(25);
    session.shortBreakMinutes = obj["shortBreakMinutes"].toInt(5);
    session.longBreakMinutes = obj["longBreakMinutes"].toInt(15);
    session.remainingSeconds = obj["remainingSeconds"].toInt(0);
    session.isPaused = obj["isPaused"].toBool(false);
    session.isActive = obj["isActive"].toBool(false);
    
    QString startTimeStr = obj["startTime"].toString();
    if (!startTimeStr.isEmpty()) {
        session.startTime = QDateTime::fromString(startTimeStr, Qt::ISODate);
    }
    
    QString lastTickStr = obj["lastTickTime"].toString();
    if (!lastTickStr.isEmpty()) {
        session.lastTickTime = QDateTime::fromString(lastTickStr, Qt::ISODate);
    }
    
    return session;
}

QJsonArray FocusSessionRepository::readHistoryArray() const {
    QFile file(m_historyPath);
    if (!file.exists()) {
        return QJsonArray();
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open history file for reading:" << m_historyPath;
        return QJsonArray();
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray()) {
        return QJsonArray();
    }

    return doc.array();
}

bool FocusSessionRepository::writeHistoryArray(const QJsonArray& array) const {
    QJsonDocument doc(array);
    
    QFile file(m_historyPath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open history file for writing:" << m_historyPath;
        return false;
    }

    file.write(doc.toJson());
    file.close();
    return true;
}
