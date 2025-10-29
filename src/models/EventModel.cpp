#include "EventModel.h"

#include <QVariantMap>

EventModel::EventModel(QObject* parent)
    : QAbstractListModel(parent) {
}

int EventModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) {
        return 0;
    }
    return m_events.size();
}

QVariant EventModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) {
        return {};
    }
    const int row = index.row();
    if (row < 0 || row >= m_events.size()) {
        return {};
    }
    const EventRecord& ev = m_events.at(row);
    switch (role) {
    case IdRole:
        return ev.id;
    case TitleRole:
        return ev.title;
    case StartRole:
        return ev.start;
    case EndRole:
        return ev.end;
    case AllDayRole:
        return ev.allDay;
    case LocationRole:
        return ev.location;
    case NotesRole:
        return ev.notes;
    case TagsRole:
        return QVariant::fromValue(ev.tags);
    case IsExamRole:
        return ev.isExam;
    case IsDoneRole:
        return ev.isDone;
    case DueRole:
        return ev.due;
    case ColorHintRole:
        return ev.colorHint;
    case PriorityRole:
        return ev.priority;
    case CategoryIdRole:
        return ev.categoryId;
    default:
        break;
    }
    return {};
}

QHash<int, QByteArray> EventModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles.insert(IdRole, "id");
    roles.insert(TitleRole, "title");
    roles.insert(StartRole, "start");
    roles.insert(EndRole, "end");
    roles.insert(AllDayRole, "allDay");
    roles.insert(LocationRole, "location");
    roles.insert(NotesRole, "notes");
    roles.insert(TagsRole, "tags");
    roles.insert(IsExamRole, "isExam");
    roles.insert(IsDoneRole, "isDone");
    roles.insert(DueRole, "due");
    roles.insert(ColorHintRole, "colorHint");
    roles.insert(PriorityRole, "priority");
    roles.insert(CategoryIdRole, "categoryId");
    return roles;
}

void EventModel::replaceAll(const QVector<EventRecord>& events) {
    beginResetModel();
    m_events = events;
    endResetModel();
}

QVariantMap EventModel::eventAt(int index) const {
    QVariantMap map;
    if (index < 0 || index >= m_events.size()) {
        return map;
    }
    const EventRecord& ev = m_events.at(index);
    map.insert(QStringLiteral("id"), ev.id);
    map.insert(QStringLiteral("title"), ev.title);
    map.insert(QStringLiteral("start"), ev.start);
    map.insert(QStringLiteral("end"), ev.end);
    map.insert(QStringLiteral("allDay"), ev.allDay);
    map.insert(QStringLiteral("location"), ev.location);
    map.insert(QStringLiteral("notes"), ev.notes);
    map.insert(QStringLiteral("tags"), QVariant::fromValue(ev.tags));
    map.insert(QStringLiteral("isExam"), ev.isExam);
    map.insert(QStringLiteral("isDone"), ev.isDone);
    map.insert(QStringLiteral("due"), ev.due);
    map.insert(QStringLiteral("colorHint"), ev.colorHint);
    map.insert(QStringLiteral("priority"), ev.priority);
    map.insert(QStringLiteral("categoryId"), ev.categoryId);
    return map;
}

int EventModel::indexOfId(const QString& id) const {
    for (int i = 0; i < m_events.size(); ++i) {
        if (m_events.at(i).id == id) {
            return i;
        }
    }
    return -1;
}
