#pragma once

#include "Category.h"

#include <QJsonArray>
#include <QString>
#include <QVector>

class CategoryRepository {
public:
    CategoryRepository();
    
    bool initialize(const QString& storageDir);
    
    QVector<Category> loadAll() const;
    bool save(const QVector<Category>& categories);
    
    Category findById(const QString& id) const;
    bool insert(const Category& category);
    bool update(const Category& category);
    bool remove(const QString& id);
    
    QString categoriesPath() const { return m_jsonPath; }
    
private:
    QString m_jsonPath;
    QVector<Category> m_categories;
    
    bool loadFromFile();
    bool saveToFile();
    QJsonArray toJsonArray() const;
    void fromJsonArray(const QJsonArray& array);
    static QVector<Category> defaultCategories();
    
    static QJsonObject categoryToJson(const Category& category);
    static Category categoryFromJson(const QJsonObject& object);
};
