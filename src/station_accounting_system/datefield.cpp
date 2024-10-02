#include "datefield.h"
#include <QMessageBox>
#include <QLabel>

DateField::DateField(QString editName, QDate maxDate, QString desc, QString warnDesc, QWidget *parent) :
    FieldTemplate(parent)
{
    setAttribute(Qt::WA_DeleteOnClose);
    this->warn = warnDesc;

    parametr = new QDateEdit();
    parametr->setMinimumDate(QDate(1900, 1, 1));
    parametr->setMaximumDate(maxDate);

    QLabel* p = new QLabel();
    p->setText(desc);

    mainLayout->addWidget(p);
    mainLayout->addWidget(parametr);


}

QVariant DateField::getCurrentValue()
{
    return parametr->date();
}

void DateField::setCurrentValue(QVariant p)
{
    if(p.canConvert<QDate>()){
        parametr->setDate(p.toDate());
    }
    else{
        QMessageBox::warning(this, tr("Ошибка системы"), "Получены неправильные данные даты. Как значение по умлочанию будет использоваться текущая дата");
        parametr->setDate(QDate::currentDate());
    }
}

void DateField::setUseable(bool v)
{
    parametr->setReadOnly(!v);
    if(!v)
        parametr->setStyleSheet("background: lightgray;");
}

DateField::~DateField()
{

}
