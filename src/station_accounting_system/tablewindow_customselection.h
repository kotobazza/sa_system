#ifndef TABLEWINDOW_CUSTOMSELECTION_H
#define TABLEWINDOW_CUSTOMSELECTION_H

#include <QWidget>
#include <QSqlQueryModel>
#include <QSqlError>
#include <QCloseEvent>

#include "tabledescription.h"
#include "fieldtemplate.h"

namespace Ui {
class TableWindow_CustomSelection;
}

class TableWindow_CustomSelection : public QWidget
{
    Q_OBJECT

public:
    explicit TableWindow_CustomSelection(TableDescription* descriptor, QWidget* parent = nullptr);
    ~TableWindow_CustomSelection();

public slots:
    void selectButtonClicked();
    void parentCloses();

private:
    Ui::TableWindow_CustomSelection *ui;

    void closeEvent(QCloseEvent* e);
    QSqlQueryModel* selectModel;
    TableDescription* descripor;
    QVector<QString> columns;
    QVector<QString> fieldsTypes;
    QVector<FieldTemplate* > fields;
    QVector<bool> isIgnored;
    QVBoxLayout* mainLayout;

};

#endif // TABLEWINDOW_CUSTOMSELECTION_H
