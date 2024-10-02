#ifndef BOOLEANFIELD_H
#define BOOLEANFIELD_H

#include "fieldtemplate.h"
#include <QCheckBox>
#include <QFrame>


class BooleanField : public FieldTemplate
{
    Q_OBJECT
public:
    explicit BooleanField(QString desc, QWidget* parent = nullptr);
    virtual QVariant getCurrentValue() override;
    virtual void setCurrentValue(QVariant) override;
    virtual void setUseable(bool) override;
    ~BooleanField();
private:
    Ui::FieldTemplate* ui;
    QCheckBox* parametr;
    QFrame* t;

};

#endif // BOOLEANFIELD_H
