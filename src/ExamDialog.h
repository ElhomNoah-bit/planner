#pragma once
#include <QDialog>
#include "core/Subject.h"
#include "core/Exam.h"

class QComboBox;
class QDateEdit;
class QLineEdit;

class ExamDialog : public QDialog {
    Q_OBJECT
public:
    explicit ExamDialog(const QList<Subject>& subjects, QWidget* parent=nullptr);
    Exam result() const;

private:
    QComboBox* m_subject;
    QDateEdit* m_date;
    QLineEdit* m_topics;
};
