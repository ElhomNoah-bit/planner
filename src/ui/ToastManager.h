#pragma once

#include <QQueue>
#include <QWidget>

class QLabel;
class QTimer;

class ToastManager : public QWidget {
    Q_OBJECT
public:
    explicit ToastManager(QWidget* parent = nullptr);

    void showToast(const QString& message, int durationMs = 3000);
    void positionToast();

private Q_SLOTS:
    void showNext();

private:
    struct ToastItem {
        QString message;
        int durationMs = 3000;
    };

    void ensureVisible();

    QLabel* m_label;
    QWidget* m_card;
    QTimer* m_timer;
    QQueue<ToastItem> m_queue;
    bool m_showing = false;
};
