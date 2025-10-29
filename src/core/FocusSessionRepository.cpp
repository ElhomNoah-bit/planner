#include "FocusSessionRepository.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUuid>
#include <QDebug>

FocusSessionRepository::FocusSessionRepository() = default;

bool FocusSessionRepository::initialize(const QString& storageDir) {
    QDir dir(storageDir);
    if (!dir.exists() && !dir.mkpath(QStringLiteral("."))) {
        qWarning() << "Failed to create storage directory:" << storageDir;
        return false;
    }

    m_jsonPath = dir.filePath(QStringLiteral("focus_sessions.json"));
    
    // Create empty array if file doesn't exist
    if (!QFile::exists(m_jsonPath)) {
        return writeJsonArray(QJsonArray());
    }
    
    return true;
}

QVector<FocusSession> FocusSessionRepository::loadAll() const {
    QJsonArray array = readJsonArray();
    QVector<FocusSession> sessions;
    sessions.reserve(array.size());
    
    for (const QJsonValue& value : array) {
        if (value.isObject()) {
            sessions.append(sessionFromJson(value.toObject()));
        }
    }
    
    return sessions;
}

QVector<FocusSession> FocusSessionRepository::loadByDate(const QDate& date) const {
    QVector<FocusSession> allSessions = loadAll();
    QVector<FocusSession> filtered;
    
    for (const FocusSession& session : allSessions) {
        if (session.start.date() == date) {
            filtered.append(session);
        }
    }
    
    return filtered;
}

QVector<FocusSession> FocusSessionRepository::loadBetween(const QDate& start, const QDate& end) const {
    QVector<FocusSession> allSessions = loadAll();
    QVector<FocusSession> filtered;
    
    for (const FocusSession& session : allSessions) {
        QDate sessionDate = session.start.date();
        if (sessionDate >= start && sessionDate <= end) {
            filtered.append(session);
        }
    }
    
    return filtered;
}

FocusSession FocusSessionRepository::loadById(const QString& id) const {
    QVector<FocusSession> allSessions = loadAll();
    
    for (const FocusSession& session : allSessions) {
        if (session.id == id) {
            return session;
        }
    }
    
    return FocusSession();
}

bool FocusSessionRepository::insert(FocusSession& session) {
    if (session.id.isEmpty()) {
        session.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    }
    
    QJsonArray array = readJsonArray();
    array.append(sessionToJson(session));
    
    return writeJsonArray(array);
}

bool FocusSessionRepository::update(const FocusSession& session) {
    QJsonArray array = readJsonArray();
    
    for (int i = 0; i < array.size(); ++i) {
        QJsonObject obj = array[i].toObject();
        if (obj[QStringLiteral("id")].toString() == session.id) {
            array[i] = sessionToJson(session);
            return writeJsonArray(array);
        }
    }
    
    return false;
}

bool FocusSessionRepository::remove(const QString& id) {
    QJsonArray array = readJsonArray();
    
    for (int i = 0; i < array.size(); ++i) {
        QJsonObject obj = array[i].toObject();
        if (obj[QStringLiteral("id")].toString() == id) {
            array.removeAt(i);
            return writeJsonArray(array);
        }
    }
    
    return false;
}

int FocusSessionRepository::getTotalMinutesForDate(const QDate& date) const {
    QVector<FocusSession> sessions = loadByDate(date);
    int totalSeconds = 0;
    
    for (const FocusSession& session : sessions) {
        if (session.completed) {
            totalSeconds += session.durationSeconds;
        }
    }
    
    return totalSeconds / 60;  // Convert to minutes
}

QMap<QDate, int> FocusSessionRepository::getWeeklyMinutes(const QDate& weekStart) const {
    QMap<QDate, int> weeklyData;
    QDate weekEnd = weekStart.addDays(6);
    
    QVector<FocusSession> sessions = loadBetween(weekStart, weekEnd);
    
    for (const FocusSession& session : sessions) {
        if (session.completed) {
            QDate date = session.start.date();
            weeklyData[date] += session.durationSeconds / 60;  // Convert to minutes
        }
    }
    
    return weeklyData;
}

QJsonArray FocusSessionRepository::readJsonArray() const {
    QFile file(m_jsonPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open focus sessions file for reading:" << m_jsonPath;
        return QJsonArray();
    }
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &error);
    file.close();
    
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse focus sessions JSON:" << error.errorString();
        return QJsonArray();
    }
    
    return doc.array();
}

bool FocusSessionRepository::writeJsonArray(const QJsonArray& array) const {
    QFile file(m_jsonPath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open focus sessions file for writing:" << m_jsonPath;
        return false;
    }
    
    QJsonDocument doc(array);
    qint64 written = file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    
    return written > 0;
}

QJsonObject FocusSessionRepository::sessionToJson(const FocusSession& session) {
    QJsonObject obj;
    obj[QStringLiteral("id")] = session.id;
    obj[QStringLiteral("taskId")] = session.taskId;
    obj[QStringLiteral("start")] = session.start.toString(Qt::ISODate);
    obj[QStringLiteral("end")] = session.end.toString(Qt::ISODate);
    obj[QStringLiteral("durationSeconds")] = session.durationSeconds;
    obj[QStringLiteral("completed")] = session.completed;
    return obj;
}

FocusSession FocusSessionRepository::sessionFromJson(const QJsonObject& obj) {
    FocusSession session;
    session.id = obj[QStringLiteral("id")].toString();
    session.taskId = obj[QStringLiteral("taskId")].toString();
    session.start = QDateTime::fromString(obj[QStringLiteral("start")].toString(), Qt::ISODate);
    session.end = QDateTime::fromString(obj[QStringLiteral("end")].toString(), Qt::ISODate);
    session.durationSeconds = obj[QStringLiteral("durationSeconds")].toInt();
    session.completed = obj[QStringLiteral("completed")].toBool();
    return session;
}
