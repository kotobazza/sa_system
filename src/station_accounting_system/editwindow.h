#ifndef EDITWINDOW_H
#define EDITWINDOW_H

#include <QWidget>
#include <QVBoxLayout>
#include <QCloseEvent>

#include "querydescription.h"
#include "fieldtemplate.h"

namespace Ui {
class EditWindow;
}

class EditWindow : public QWidget
{
    Q_OBJECT

public:
    explicit EditWindow(QueryDescription* desc, QVector<QString> oldData, QWidget *parent = nullptr);
    ~EditWindow();

signals:
    void success();



public slots:
    void parentCloses();
    void acceptButton_clicked();

private:
    Ui::EditWindow *ui;
    QueryDescription* query;
    QVector<QString> fieldsTypes;
    QVector<FieldTemplate* > fields;
    QVector<bool> isIgnored;
    QVBoxLayout* mainLayout;
    QVector<QString> OLD;
};

#endif // EDITWINDOW_H
