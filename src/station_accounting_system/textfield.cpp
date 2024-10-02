#include "textfield.h"
#include <QLabel>
#include <QMessageBox>

TextField::TextField(QString editName, QString desc, QString warnDesc, QRegularExpression re, QWidget* parent) :
    FieldTemplate(parent)
{
    setAttribute(Qt::WA_DeleteOnClose);
    this->re = re;
    QLabel* text = new QLabel(desc);
    warn = warnDesc;
    mainLayout->addWidget(text);
    parametr = new QLineEdit();
    parametr->resize(100, 40);
    mainLayout->addWidget(parametr);
    this->editName = editName;
    connect(parametr, &QLineEdit::editingFinished, this, &TextField::on_lineEdit_changeCurrentText);
}

TextField::~TextField()
{

}

QVariant TextField::getCurrentValue()
{
    if(!re.match(parametr->text()).hasMatch()){
        QMessageBox::warning(this, tr("Ошибка ввода"), "Введенное значение для параметра '" + editName + "' не может быть использовано\n" + warn);
        if(!parametr->isReadOnly())
            parametr->setStyleSheet("border: 1px solid red;");
        return -1;
    }
    else{
        return parametr->text();
    }
}

void TextField::setCurrentValue(QVariant p)
{
    parametr->setText(p.toString());
}

void TextField::setUseable(bool val)
{
    parametr->setReadOnly(!val);
    parametr->setStyleSheet("background: lightgray;");
}

void TextField::on_lineEdit_changeCurrentText()
{
    parametr->setStyleSheet("border: 1px solid black;");
    if(parametr->isReadOnly())
        parametr->setStyleSheet("background: lightgray;");
}



