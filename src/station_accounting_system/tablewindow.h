#ifndef TABLEWINDOW_H
#define TABLEWINDOW_H

#include <QWidget>
#include <QMap>
#include <QVector>
#include <QtSql/QSqlQueryModel>
#include <QtSql/QSqlQuery>
#include <QCloseEvent>

#include "tabledescription.h"
#include "editwindow.h"


namespace Ui {
class TableWindow;
}

class TableWindow : public QWidget
{
    Q_OBJECT

public:
    /*
        итоговый вектор содержит набор одинаковых по структуре диктов
            - название кнопки
            - запрос
            - форма запроса (используемые типы данных)
            - названия полей
        мапа 0 отходит на запрос для самой таблицы, остальные могут использоваться как кнопки


        или же это будет мапа, а не вектор
        в основной мапе валяется тип кнопки и еще мапа
            в мапе валяются следующие вещи:
                name:<название кнопки>
                query:<запрос>
                query_form:<типовая форма запроса> (разделитель пробел)
                query_names:<названия полей> (разделитель ' ')
                default_desc:<строка для описания дейтсвия внутри editwindow>
        QMap<QString, QMap<QString, QString>> queryForm;
    */

    explicit TableWindow(TableDescription* descriptor, QWidget* parent = nullptr);
    ~TableWindow();
signals:
    void windowCloses();


public slots:
    void parentCloses();
    void editorSuccess();
    void button0_clicked();
    void button1_clicked();
    void button2_clicked();
    void button3_clicked();

private:
    void closeEvent(QCloseEvent* e);

    Ui::TableWindow *ui;
    EditWindow* editor;
    QSqlQueryModel* selectModel;
    TableDescription* descripor;
    QVector<QString> columns;
};

#endif // TABLEWINDOW_H
