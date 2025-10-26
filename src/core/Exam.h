#pragma once

#include <QDate>
#include <QString>
#include <QStringList>

struct Exam {
    QString id;
    QString subjectId;
    QDate date;
    QStringList topics;
    double weightBoost = 1.3;
};
