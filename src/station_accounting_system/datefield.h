#ifndef DATEFIELD_H
#define DATEFIELD_H

#include <QDate>
#include <QDateEdit>
#include "fieldtemplate.h"

class DateField : public FieldTemplate
{
    Q_OBJECT
public:
    DateField(QString editName, QDate currentDate, QString desc, QString warnDesc, QWidget* parent=nullptr);
    virtual QVariant getCurrentValue() override;
    virtual void setCurrentValue(QVariant) override;
    virtual void setUseable(bool);
    ~DateField();

private:
    QDateEdit* parametr;
    QString warn;
    Ui::FieldTemplate* ui;

};

#endif // DATEFIELD_H
