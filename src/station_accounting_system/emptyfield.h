#ifndef EMPTYFIELD_H
#define EMPTYFIELD_H

#include "fieldtemplate.h"

class EmptyField : public FieldTemplate
{
    Q_OBJECT
public:
    EmptyField(QWidget* parent = nullptr);
    virtual QVariant getCurrentValue() override;
    virtual void setCurrentValue(QVariant) override;
    virtual void setUseable(bool);
    ~EmptyField();

private:
    QVariant value;
    Ui::FieldTemplate* ui;
};

#endif // EMPTYFIELD_H
