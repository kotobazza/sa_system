#include "fieldtemplate.h"
#include "ui_fieldtemplate.h"

FieldTemplate::FieldTemplate(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::FieldTemplate)
{
    setAttribute(Qt::WA_DeleteOnClose);
    ui->setupUi(this);
    mainLayout = new QVBoxLayout(this);
}

FieldTemplate::~FieldTemplate()
{
    delete ui;
}
