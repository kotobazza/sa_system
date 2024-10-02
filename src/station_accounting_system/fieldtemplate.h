#ifndef FIELDTEMPLATE_H
#define FIELDTEMPLATE_H

#include <QWidget>
#include <QVariant>
#include <QVBoxLayout>


namespace Ui {
class FieldTemplate;
}

class FieldTemplate : public QWidget
{
    Q_OBJECT

public:
    explicit FieldTemplate(QWidget *parent = nullptr);
    ~FieldTemplate();

    virtual QVariant getCurrentValue() = 0;
    virtual void setCurrentValue(QVariant) = 0;
    virtual void setUseable(bool) = 0;

    QVBoxLayout* mainLayout;
    Ui::FieldTemplate *ui;
private:

};

#endif // FIELDTEMPLATE_H
