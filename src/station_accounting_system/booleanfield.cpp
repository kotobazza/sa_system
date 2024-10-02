#include "booleanfield.h"
#include <QLabel>
#include <QMessageBox>
#include <QFrame>
#include <QHBoxLayout>



BooleanField::BooleanField(QString desc, QWidget *parent) :
    FieldTemplate(parent)
{
    QLabel* text = new QLabel();
    text->setText(desc);

    parametr = new QCheckBox();

    t = new QFrame();
    t->setStyleSheet("padding: 3px;");

    QHBoxLayout* a = new QHBoxLayout();

    a->addWidget(parametr);
    t->setLayout(a);


    QFrame* p = new QFrame();
    QHBoxLayout* n = new QHBoxLayout();
    n->addWidget(text);
    n->addWidget(t);

    p->setLayout(n);
    n->setAlignment(Qt::AlignJustify);


    mainLayout->addWidget(p);
}

QVariant BooleanField::getCurrentValue()
{
    return parametr->isChecked();
}

void BooleanField::setCurrentValue(QVariant p)
{
    if(p.canConvert<bool>()){
        if(p.toBool())
            parametr->setChecked(true);
    }
    else{
        QMessageBox::critical(this, tr("Ошибка системы"), "Получена ошибка представления значения поля.");
    }
}

void BooleanField::setUseable(bool p)
{
    parametr->setCheckable(p);
    if(!p)
        t->setStyleSheet("padding: 3px;background: lightgray;");
}

BooleanField::~BooleanField()
{

}
