#pragma once

#include <QToolButton>

class FilterChip : public QToolButton {
    Q_OBJECT
public:
    explicit FilterChip(const QString& label, QWidget* parent = nullptr);

    bool isActive() const { return m_active; }
    void setActive(bool active);

signals:
    void activeChanged(bool active);

protected:
    void paintEvent(QPaintEvent* event) override;
    void nextCheckState() override;

private:
    bool m_active = false;
};
