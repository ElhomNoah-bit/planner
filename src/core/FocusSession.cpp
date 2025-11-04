#include "FocusSession.h"

#include <QJsonValue>

FocusSession::FocusSession(const QDateTime& start, const QDateTime& end, bool completed)
    : m_start(start), m_end(end), m_completed(completed) {
}

bool FocusSession::isValid() const {
    return m_start.isValid() && m_end.isValid() && m_start <= m_end;
}

int FocusSession::durationMinutes() const {
    if (!isValid()) {
        return 0;
    }
    return static_cast<int>(m_start.secsTo(m_end) / 60);
}

QDate FocusSession::date() const {
    if (m_start.isValid()) {
        return m_start.date();
    }
    return QDate();
}

QJsonObject FocusSession::toJson() const {
    QJsonObject obj;
    obj.insert(QStringLiteral("start"), m_start.toString(Qt::ISODate));
    obj.insert(QStringLiteral("end"), m_end.toString(Qt::ISODate));
    obj.insert(QStringLiteral("completed"), m_completed);
    return obj;
}

FocusSession FocusSession::fromJson(const QJsonObject& object) {
    const QDateTime start = QDateTime::fromString(object.value(QStringLiteral("start")).toString(), Qt::ISODate);
    const QDateTime end = QDateTime::fromString(object.value(QStringLiteral("end")).toString(), Qt::ISODate);
    const bool completed = object.value(QStringLiteral("completed")).toBool(false);
    return FocusSession(start, end, completed);
}
