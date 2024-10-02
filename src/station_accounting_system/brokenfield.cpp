#include "brokenfield.h"
#include <QLabel>
#include <QVBoxLayout>


BrokenField::BrokenField(QWidget *parent) :
    FieldTemplate(parent)
{
    QLabel* p = new QLabel();
    p->setText("Этот текст появляется при получении ошибки <BROKENFIELD>");
    p->setStyleSheet("color: red; font-weight:bold;");
    mainLayout->addWidget(p);

}

QVariant BrokenField::getCurrentValue()
{
    return value;
}

void BrokenField::setCurrentValue(QVariant p)
{
    this->value = p;
}

void BrokenField::setUseable(bool)
{

}

BrokenField::~BrokenField()
{

}
