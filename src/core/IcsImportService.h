#pragma once

#include "Category.h"
#include "EventRepository.h"

#include <QDateTime>
#include <QNetworkAccessManager>
#include <QObject>
#include <QStringList>
#include <QTimer>
#include <QVariantMap>

class CategoryRepository;
class QNetworkReply;

class IcsImportService : public QObject {
    Q_OBJECT
public:
    explicit IcsImportService(EventRepository* repository,
                              CategoryRepository* categoryRepository,
                              QObject* parent = nullptr);

    QVariantMap status() const;

    QString url() const { return m_url; }
    bool autoSync() const { return m_autoSync; }
    bool isSyncing() const { return m_syncing; }
    QDateTime lastSync() const { return m_lastSync; }
    QString lastError() const { return m_lastError; }
    bool linkValid() const { return m_linkValid; }

public slots:
    void setUrl(const QString& url);
    void setAutoSync(bool enabled);
    void syncNow();
    void disconnect(bool keepEvents);

signals:
    void statusChanged();
    void eventsUpdated();

private:
    struct ParsedEvent {
        QString uid;
        QString title;
        QString location;
        QString description;
        QStringList categories;
        QDateTime start;
        QDateTime end;
        bool allDay = false;
    };

    void loadState();
    void saveState() const;
    void scheduleAutoSync();
    void handleReply(QNetworkReply* reply);
    void completeSync(bool success, const QString& errorMessage = QString());
    void ensureUntisCategory();
    QVector<ParsedEvent> parseIcs(const QByteArray& payload) const;
    EventRecord buildRecord(const ParsedEvent& input) const;
    QString computeExternalId(const ParsedEvent& input) const;
    QString detectEventType(const ParsedEvent& input) const;

    EventRepository* m_repository = nullptr;
    CategoryRepository* m_categoryRepository = nullptr;
    QNetworkAccessManager m_network;
    QTimer m_autoTimer;

    QString m_url;
    bool m_autoSync = false;
    QDateTime m_lastSync;
    QString m_lastError;
    bool m_linkValid = true;
    bool m_syncing = false;
};
