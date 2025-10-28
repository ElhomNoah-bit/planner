#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QStringList>
#include <QVector>

struct EventRecord {
    QString id;
    QString title;
    QDateTime start;
    QDateTime end;
    bool allDay = false;
    QString location;
    QString notes;
    QStringList tags;
    bool isExam = false;
    bool isDone = false;
    QDateTime due;
    QString colorHint;
    int priority = 0;
};

class EventModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        StartRole,
        EndRole,
        AllDayRole,
        LocationRole,
        NotesRole,
        TagsRole,
        IsExamRole,
        IsDoneRole,
        DueRole,
        ColorHintRole,
        PriorityRole
    };
    Q_ENUM(Roles)

    explicit EventModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void replaceAll(const QVector<EventRecord>& events);
    QVector<EventRecord> events() const { return m_events; }
    QVariantMap eventAt(int index) const;
    int indexOfId(const QString& id) const;

private:
    QVector<EventRecord> m_events;
};
