#pragma once

#include <QString>
#include <QColor>

struct Category {
    QString id;
    QString name;
    QColor color;
    
    bool isValid() const {
        return !id.isEmpty() && !name.isEmpty();
    }
};
