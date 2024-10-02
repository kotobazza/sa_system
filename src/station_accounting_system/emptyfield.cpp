#include "emptyfield.h"

EmptyField::EmptyField(QWidget* parent) :
    FieldTemplate(parent)
{
    this->setGeometry(0, 0, 0, 0);
}

QVariant EmptyField::getCurrentValue()
{
    return value;
}

void EmptyField::setCurrentValue(QVariant p)
{
    this->value = p;
}

void EmptyField::setUseable(bool)
{

}

EmptyField::~EmptyField()
{

}
