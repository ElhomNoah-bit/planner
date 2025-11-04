#pragma once

#include <QDate>
#include <QDateTime>
#include <QJsonObject>
#include <QString>

class FocusSession {
public:
    FocusSession() = default;
    FocusSession(const QDateTime& start, const QDateTime& end, bool completed);

    bool isValid() const;
    QDateTime start() const { return m_start; }
    QDateTime end() const { return m_end; }
    bool completed() const { return m_completed; }
    int durationMinutes() const;
    QDate date() const;

    QJsonObject toJson() const;
    static FocusSession fromJson(const QJsonObject& object);

private:
    QDateTime m_start;
    QDateTime m_end;
    bool m_completed = false;
};
