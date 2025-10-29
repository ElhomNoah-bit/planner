#include "CategoryRepository.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

CategoryRepository::CategoryRepository() = default;

bool CategoryRepository::initialize(const QString& storageDir) {
    if (storageDir.isEmpty()) {
        qWarning() << "[CategoryRepository] Storage directory is empty";
        return false;
    }
    
    QDir dir(storageDir);
    if (!dir.exists() && !dir.mkpath(QStringLiteral("."))) {
        qWarning() << "[CategoryRepository] Failed to create storage directory:" << storageDir;
        return false;
    }
    
    m_jsonPath = dir.filePath(QStringLiteral("categories.json"));
    
    if (!QFile::exists(m_jsonPath)) {
        // Create default categories for school subjects
        QVector<Category> defaults;
        defaults.append({QStringLiteral("math"), QStringLiteral("Mathematik"), QColor(QStringLiteral("#3B82F6"))});
        defaults.append({QStringLiteral("german"), QStringLiteral("Deutsch"), QColor(QStringLiteral("#10B981"))});
        defaults.append({QStringLiteral("english"), QStringLiteral("Englisch"), QColor(QStringLiteral("#F59E0B"))});
        defaults.append({QStringLiteral("science"), QStringLiteral("Naturwissenschaften"), QColor(QStringLiteral("#8B5CF6"))});
        defaults.append({QStringLiteral("history"), QStringLiteral("Geschichte"), QColor(QStringLiteral("#EF4444"))});
        defaults.append({QStringLiteral("other"), QStringLiteral("Sonstiges"), QColor(QStringLiteral("#6B7280"))});
        
        m_categories = defaults;
        if (!saveToFile()) {
            qWarning() << "[CategoryRepository] Failed to save default categories";
            return false;
        }
    } else {
        if (!loadFromFile()) {
            qWarning() << "[CategoryRepository] Failed to load categories";
            return false;
        }
    }
    
    return true;
}

QVector<Category> CategoryRepository::loadAll() const {
    return m_categories;
}

bool CategoryRepository::save(const QVector<Category>& categories) {
    m_categories = categories;
    return saveToFile();
}

Category CategoryRepository::findById(const QString& id) const {
    for (const auto& cat : m_categories) {
        if (cat.id == id) {
            return cat;
        }
    }
    return Category();
}

bool CategoryRepository::insert(const Category& category) {
    if (!category.isValid()) {
        return false;
    }
    
    // Check for duplicate ID
    if (findById(category.id).isValid()) {
        qWarning() << "[CategoryRepository] Category with ID already exists:" << category.id;
        return false;
    }
    
    m_categories.append(category);
    return saveToFile();
}

bool CategoryRepository::update(const Category& category) {
    if (!category.isValid()) {
        return false;
    }
    
    for (int i = 0; i < m_categories.size(); ++i) {
        if (m_categories[i].id == category.id) {
            m_categories[i] = category;
            return saveToFile();
        }
    }
    
    qWarning() << "[CategoryRepository] Category not found:" << category.id;
    return false;
}

bool CategoryRepository::remove(const QString& id) {
    for (int i = 0; i < m_categories.size(); ++i) {
        if (m_categories[i].id == id) {
            m_categories.removeAt(i);
            return saveToFile();
        }
    }
    
    qWarning() << "[CategoryRepository] Category not found:" << id;
    return false;
}

bool CategoryRepository::loadFromFile() {
    QFile file(m_jsonPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[CategoryRepository] Failed to open file for reading:" << m_jsonPath;
        return false;
    }
    
    QByteArray data = file.readAll();
    file.close();
    
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray()) {
        qWarning() << "[CategoryRepository] JSON is not an array";
        return false;
    }
    
    fromJsonArray(doc.array());
    return true;
}

bool CategoryRepository::saveToFile() {
    QFile file(m_jsonPath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "[CategoryRepository] Failed to open file for writing:" << m_jsonPath;
        return false;
    }
    
    QJsonDocument doc(toJsonArray());
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    
    return true;
}

QJsonArray CategoryRepository::toJsonArray() const {
    QJsonArray array;
    for (const auto& cat : m_categories) {
        array.append(categoryToJson(cat));
    }
    return array;
}

void CategoryRepository::fromJsonArray(const QJsonArray& array) {
    m_categories.clear();
    for (const auto& value : array) {
        if (value.isObject()) {
            Category cat = categoryFromJson(value.toObject());
            if (cat.isValid()) {
                m_categories.append(cat);
            }
        }
    }
}

QJsonObject CategoryRepository::categoryToJson(const Category& category) {
    QJsonObject obj;
    obj.insert(QStringLiteral("id"), category.id);
    obj.insert(QStringLiteral("name"), category.name);
    obj.insert(QStringLiteral("color"), category.color.name());
    return obj;
}

Category CategoryRepository::categoryFromJson(const QJsonObject& object) {
    Category cat;
    cat.id = object.value(QStringLiteral("id")).toString();
    cat.name = object.value(QStringLiteral("name")).toString();
    
    QString colorStr = object.value(QStringLiteral("color")).toString();
    if (!colorStr.isEmpty()) {
        cat.color = QColor(colorStr);
    }
    
    return cat;
}
