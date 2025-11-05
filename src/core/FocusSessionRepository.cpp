#include "FocusSessionRepository.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>
#include <QtDebug>
#include <QtGlobal>

#include <algorithm>

FocusSessionRepository::FocusSessionRepository() = default;

void FocusSessionRepository::setStorageDirectory(const QString& directory) {
    m_storageDir = directory;
    m_loaded = false;
    m_stateLoaded = false;
    m_cache.clear();
    m_activeStart = QDateTime();

    if (!m_storageDir.isEmpty()) {
        QDir dir(m_storageDir);
        if (!dir.exists()) {
            dir.mkpath(QStringLiteral("."));
        }
    }
}

bool FocusSessionRepository::hasActiveSession() const {
    ensureStateLoaded();
    return m_activeStart.isValid();
}

QDateTime FocusSessionRepository::activeSessionStart() const {
    ensureStateLoaded();
    return m_activeStart;
}

bool FocusSessionRepository::startSession(const QDateTime& start) {
    ensureStateLoaded();
    if (m_activeStart.isValid()) {
        return false;
    }
    m_activeStart = start.isValid() ? start : QDateTime::currentDateTime();
    saveState();
    return true;
}

FocusSession FocusSessionRepository::finishSession(const QDateTime& end, bool completed) {
    ensureStateLoaded();
    if (!m_activeStart.isValid()) {
        return FocusSession();
    }

    QDateTime actualEnd = end.isValid() ? end : QDateTime::currentDateTime();
    if (actualEnd < m_activeStart) {
        actualEnd = m_activeStart;
    }

    FocusSession session(m_activeStart, actualEnd, completed);

    ensureLoaded();
    QVector<FocusSession> sessions = m_cache;
    sessions.append(session);
    saveSessions(sessions);

    m_cache = sessions;
    m_activeStart = QDateTime();
    saveState();
    return session;
}

void FocusSessionRepository::cancelActiveSession() {
    ensureStateLoaded();
    if (!m_activeStart.isValid()) {
        return;
    }
    m_activeStart = QDateTime();
    saveState();
}

QVector<FocusSession> FocusSessionRepository::sessions() const {
    ensureLoaded();
    return m_cache;
}

int FocusSessionRepository::currentStreak(const QDate& today) const {
    ensureLoaded();
    if (!today.isValid()) {
        return 0;
    }

    QSet<QDate> completedDays;
    for (const auto& session : m_cache) {
        if (session.completed()) {
            completedDays.insert(session.date());
        }
    }

    int streak = 0;
    QDate cursor = today;
    while (completedDays.contains(cursor)) {
        streak += 1;
        cursor = cursor.addDays(-1);
    }
    return streak;
}

QString FocusSessionRepository::sessionsPath() const {
    return QDir(m_storageDir).filePath(QStringLiteral("focus_sessions.json"));
}

QString FocusSessionRepository::statePath() const {
    return QDir(m_storageDir).filePath(QStringLiteral("focus_session_state.json"));
}

void FocusSessionRepository::ensureLoaded() const {
    if (m_loaded) {
        return;
    }
    m_loaded = true;
    m_cache.clear();

    const QString path = sessionsPath();
    QFile file(path);
    if (!file.exists()) {
        return;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[FocusSessionRepository] Cannot open" << path << file.errorString();
        return;
    }

    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();
    if (!doc.isArray()) {
        return;
    }

    const QJsonArray array = doc.array();
    m_cache.reserve(array.size());
    for (const QJsonValue& value : array) {
        if (!value.isObject()) {
            continue;
        }
        FocusSession session = FocusSession::fromJson(value.toObject());
        if (session.isValid()) {
            m_cache.append(session);
        }
    }

    std::sort(m_cache.begin(), m_cache.end(), [](const FocusSession& a, const FocusSession& b) {
        return a.start() < b.start();
    });
}

void FocusSessionRepository::ensureStateLoaded() const {
    if (m_stateLoaded) {
        return;
    }
    m_stateLoaded = true;
    m_activeStart = QDateTime();

    const QString path = statePath();
    QFile file(path);
    if (!file.exists()) {
        return;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[FocusSessionRepository] Cannot open state file" << path << file.errorString();
        return;
    }
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();
    if (!doc.isObject()) {
        return;
    }
    const QJsonObject obj = doc.object();
    const QString startIso = obj.value(QStringLiteral("start")).toString();
    const QDateTime start = QDateTime::fromString(startIso, Qt::ISODate);
    if (start.isValid()) {
        m_activeStart = start;
    }
}

void FocusSessionRepository::saveSessions(const QVector<FocusSession>& sessions) const {
    QJsonArray array;
#if QT_VERSION >= QT_VERSION_CHECK(6, 7, 0)
    array.reserve(sessions.size());
#endif
    for (const auto& session : sessions) {
        if (session.isValid()) {
            array.append(session.toJson());
        }
    }
    const QString path = sessionsPath();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "[FocusSessionRepository] Cannot save sessions" << path << file.errorString();
        return;
    }
    QJsonDocument doc(array);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
}

void FocusSessionRepository::saveState() const {
    const QString path = statePath();
    QFile file(path);
    if (m_activeStart.isValid()) {
        if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            qWarning() << "[FocusSessionRepository] Cannot store active state" << path << file.errorString();
            return;
        }
        QJsonObject obj;
        obj.insert(QStringLiteral("start"), m_activeStart.toString(Qt::ISODate));
        QJsonDocument doc(obj);
        file.write(doc.toJson(QJsonDocument::Compact));
        file.close();
    } else {
        if (file.exists() && !file.remove()) {
            qWarning() << "[FocusSessionRepository] Cannot remove state file" << path << file.errorString();
        }
    }
}
