#include "ExamDialog.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QComboBox>
#include <QDateEdit>
#include <QLineEdit>
#include <QDialogButtonBox>

ExamDialog::ExamDialog(const QList<Subject>& subjects, QWidget* parent)
    : QDialog(parent)
{
    setWindowTitle("Klassenarbeit hinzufügen");
    auto* lay = new QVBoxLayout(this);

    auto* row1 = new QHBoxLayout();
    row1->addWidget(new QLabel("Fach:"));
    m_subject = new QComboBox(this);
    for (const auto& s : subjects) m_subject->addItem(s.name, s.id);
    row1->addWidget(m_subject);
    lay->addLayout(row1);

    auto* row2 = new QHBoxLayout();
    row2->addWidget(new QLabel("Datum:"));
    m_date = new QDateEdit(QDate::currentDate(), this);
    m_date->setCalendarPopup(true);
    row2->addWidget(m_date);
    lay->addLayout(row2);

    auto* row3 = new QHBoxLayout();
    row3->addWidget(new QLabel("Themen (Komma):"));
    m_topics = new QLineEdit(this);
    row3->addWidget(m_topics);
    lay->addLayout(row3);

    auto* buttons = new QDialogButtonBox(QDialogButtonBox::Ok|QDialogButtonBox::Cancel, this);
    connect(buttons, &QDialogButtonBox::accepted, this, &ExamDialog::accept);
    connect(buttons, &QDialogButtonBox::rejected, this, &ExamDialog::reject);
    lay->addWidget(buttons);
}

Exam ExamDialog::result() const {
    Exam e;
    e.subjectId = m_subject->currentData().toString();
    e.date = m_date->date();
    for (auto piece : m_topics->text().split(",", Qt::SkipEmptyParts)) e.topics << piece.trimmed();
    e.id = e.subjectId + "_" + e.date.toString(Qt::ISODate);
    return e;
}
