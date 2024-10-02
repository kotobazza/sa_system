#ifndef DATETIMEFIELD_H
#define DATETIMEFIELD_H

#include "fieldtemplate.h"
#include <QDateTime>
#include <QDateTimeEdit>

class DateTimeField : public FieldTemplate
{
    Q_OBJECT
public:
    DateTimeField(QString editName, QDateTime currentDateTime, QString desc, QString warnDesc, QWidget* parent=nullptr);
    virtual QVariant getCurrentValue() override;
    virtual void setCurrentValue(QVariant) override;
    virtual void setUseable(bool);
    ~DateTimeField();
private:
    QDateTimeEdit* parametr;
    QString warn;
    Ui::FieldTemplate* ui;

};

#endif // DATETIMEFIELD_H
