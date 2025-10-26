#pragma once

#include <QSet>
#include <QSortFilterProxyModel>

class TaskFilterProxy : public QSortFilterProxyModel {
    Q_OBJECT
public:
    explicit TaskFilterProxy(QObject* parent = nullptr);

    void setSubjectFilter(const QSet<QString>& subjects);
    void setSearchQuery(const QString& query);
    void setOnlyOpen(bool onlyOpen);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;

private:
    QSet<QString> m_subjects;
    QString m_query;
    bool m_onlyOpen = false;
};
