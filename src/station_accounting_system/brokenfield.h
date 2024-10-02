#ifndef BROKENFIELD_H
#define BROKENFIELD_H

#include "fieldtemplate.h"

class BrokenField : public FieldTemplate
{
    Q_OBJECT
public:
    BrokenField(QWidget* parent = nullptr);
    virtual QVariant getCurrentValue() override;
    virtual void setCurrentValue(QVariant) override;
    virtual void setUseable(bool);
    ~BrokenField();

private:
    QVariant value;
    Ui::FieldTemplate* ui;
};

#endif // BROKENFIELD_H
