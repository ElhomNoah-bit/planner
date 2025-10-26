#include "ToastManager.h"

#include <QFrame>
#include <QLabel>
#include <QTimer>
#include <QVBoxLayout>

ToastManager::ToastManager(QWidget* parent)
    : QWidget(parent), m_label(new QLabel(this)), m_card(new QFrame(this)), m_timer(new QTimer(this)) {
    setAttribute(Qt::WA_TransparentForMouseEvents);
    setAttribute(Qt::WA_StyledBackground);
    setFocusPolicy(Qt::NoFocus);
    setVisible(false);

    m_card->setObjectName("toastCard");
    m_card->setStyleSheet("#toastCard { background: rgba(15, 23, 42, 0.92); border-radius: 12px; padding: 12px 20px; color: #E6EDF7; }");

    m_label->setWordWrap(true);
    m_label->setAlignment(Qt::AlignCenter);

    auto* cardLayout = new QVBoxLayout(m_card);
    cardLayout->setContentsMargins(16, 10, 16, 10);
    cardLayout->addWidget(m_label);

    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->addWidget(m_card);

    m_timer->setSingleShot(true);
    connect(m_timer, &QTimer::timeout, this, &ToastManager::showNext);
}

void ToastManager::showToast(const QString& message, int durationMs) {
    ToastItem item;
    item.message = message;
    item.durationMs = durationMs;
    m_queue.enqueue(item);
    if (!m_showing) showNext();
}

void ToastManager::positionToast() {
    if (!parentWidget()) return;
    const QRect parentRect = parentWidget()->rect();
    const QSize cardSize = m_card->sizeHint();
    const int x = parentRect.center().x() - cardSize.width() / 2;
    const int y = parentRect.bottom() - cardSize.height() - 32;
    m_card->resize(cardSize);
    setGeometry(x, y, cardSize.width(), cardSize.height());
}

void ToastManager::showNext() {
    if (m_queue.isEmpty()) {
        m_showing = false;
        setVisible(false);
        return;
    }

    const ToastItem item = m_queue.dequeue();
    m_label->setText(item.message);
    m_card->adjustSize();
    positionToast();

    ensureVisible();
    m_showing = true;
    m_timer->start(item.durationMs);
}

void ToastManager::ensureVisible() {
    setVisible(true);
    raise();
}
