#ifndef TEXTFIELD_H
#define TEXTFIELD_H

#include <fieldtemplate.h>
#include <QWidget>
#include <QRegularExpression>
#include <QLineEdit>


class TextField : public FieldTemplate
{
    Q_OBJECT
public:
    explicit TextField(QString editName, QString desc, QString warnDesc, QRegularExpression re, QWidget* parent = nullptr);
    ~TextField();
    virtual QVariant getCurrentValue() override;
    virtual void setCurrentValue(QVariant) override;
    virtual void setUseable(bool) override;

public slots:
    void on_lineEdit_changeCurrentText();

private:
    QRegularExpression re;
    Ui::FieldTemplate* ui;
    QLineEdit* parametr;
    QString editName;
    QString warn;
};

#endif // TEXTFIELD_H
