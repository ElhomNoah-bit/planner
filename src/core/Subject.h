#pragma once

#include <QColor>
#include <QString>

struct Subject {
    QString id;
    QString name;
    double weight = 1.0;
    QColor color;
};
