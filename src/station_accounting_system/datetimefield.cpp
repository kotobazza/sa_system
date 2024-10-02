#include "datetimefield.h"
#include <QLabel>
#include <QMessageBox>

DateTimeField::DateTimeField(QString editName, QDateTime maxDate, QString desc, QString warnDesc, QWidget *parent) :
    FieldTemplate(parent)
{
    setAttribute(Qt::WA_DeleteOnClose);
    this->warn = warnDesc;

    parametr = new QDateTimeEdit();
    parametr->setMinimumDate(QDate(1900, 1, 1));
    parametr->setMaximumDateTime(maxDate);

    QLabel* p = new QLabel();
    p->setText(desc);

    mainLayout->addWidget(p);
    mainLayout->addWidget(parametr);


}

QVariant DateTimeField::getCurrentValue()
{
    return parametr->date();
}

void DateTimeField::setCurrentValue(QVariant p)
{
    if(p.canConvert<QDate>()){
        parametr->setDate(p.toDate());
    }
    else{
        QMessageBox::warning(this, tr("Ошибка системы"), "Получены неправильные данные даты. Как значение по умлочанию будет использоваться текущая дата");
        parametr->setDate(QDate::currentDate());
    }
}

void DateTimeField::setUseable(bool v)
{
    parametr->setReadOnly(!v);
    if(!v)
        parametr->setStyleSheet("background: lightgray;");
}

DateTimeField::~DateTimeField()
{

}
