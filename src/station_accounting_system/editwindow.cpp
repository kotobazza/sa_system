#include "editwindow.h"
#include "ui_editwindow.h"
#include "fieldtemplate.h"
#include "textfield.h"
#include "brokenfield.h"
#include "emptyfield.h"
#include "booleanfield.h"
#include "datefield.h"
#include "datetimefield.h"

#include <QRegularExpression>
#include <QPushButton>
#include <QVBoxLayout>
#include <QDate>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QMessageBox>
#include <QDebug>



EditWindow::EditWindow(QueryDescription *desc, QVector<QString> oldData, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::EditWindow)
{
    setAttribute(Qt::WA_DeleteOnClose);
    ui->setupUi(this);
    mainLayout = new QVBoxLayout(this);

    this->query = desc;
    this->OLD = oldData;
    this->setWindowTitle("Действие '" + query->buttonText + "'");

    this->move(this->x() + 100, this->y() + 100);


    QVector<QString> fieldTypes = query->queryTypes.split(" ").toVector();
    this->fieldsTypes = fieldTypes;
    QVector<QString> columns = query->columnsNames.split("' '").toVector();

    assert(fieldTypes.size() == columns.size());


    QString descPreload;
    if(query->queryType == "insert")
        descPreload = "Дайте новое значение полю '";
    else if(query->queryType == "update")
        descPreload = "Измените значение поля '";
    else if(query->queryType == "delete")
        descPreload = "Это поле будет удалено: '";


    /*!
     * т.к. кол-во названий столбцов всегда равно кол-ву типов столбцов
     * команды инсерт и апдейт вставляют только те значения, которые им нужны для вставки
     * айди по умолчанию игнорируется, поэтому его нужно добавить в апдейте перед вставкой значений из созданных
     * полей
    */

    for(int i = 0; i< fieldTypes.size(); i++){
        FieldTemplate* editField;
        QString d = descPreload + columns[i] + "'";

        if(fieldTypes[i] == "text"){
            QRegularExpression re("^[А-Яа-я ,.-0-9]{0,255}$");
            QString warn = "Это поле может содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }

        else if(fieldTypes[i] == "text10_passport"){
            QRegularExpression re("^[0-9]{10}$");
            QString warn = "Это поле должно содержать 10 подряд идущих цифр";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }

        else if(fieldTypes[i] == "text30"){
            QRegularExpression re("^[А-Я]{1}[А-Яа-я ]{1,29}$");
            QString warn = "Это поле должно содержать первую прописную и остальные строчные символы кириллицы или пробел (всего 30 штук)";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }

        else if(fieldTypes[i] == "text30_optional"){
            QRegularExpression re("^[А-Я]{0,1}[А-Яа-я ]{0,29}$");
            QString warn = "Это поле может содержать первую прописную и остальные строчные символы кириллицы или пробел (всего 30 штук)";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }

        else if(fieldTypes[i] == "text10_train"){
            QRegularExpression re("^TRA[0-9]{1,7}$");
            QString warn = "Это поле должно содержать индекс поезда (TRA) и 1-7 цифр номера поезда";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }
        else if(fieldTypes[i] == "text10_carriage"){
            QRegularExpression re("^CARR[0-9]{1,6}$");
            QString warn = "Это поле должно содержать индекс вагона (CARR) и 1-6 цифр номера вагона";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }
        else if(fieldTypes[i] == "text10_route"){
            QRegularExpression re("^[A-Z]{1}[0-9]{1,9}");
            QString warn = "Это поле должно содержать индекс маршрута (одна из прописных букв латиницы) и 1-9 цифр номера маршрута";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }
        else if(fieldTypes[i] == "integer"){
            QRegularExpression re("^[0-9]{1,7}$");
            QString warn = "Это поле должно содержать число, состоящее максимум из 7 цифр";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
        }

        else if(fieldTypes[i] == "date"){
            QString warn = "Это поле должно содержать дату, минимальная дата для установки 1 января 1900 года";
            editField = new DateField(columns[i], QDate(2030, 01, 01), d, warn);
            isIgnored.append(false);
        }
        else if(fieldTypes[i] == "birthDate"){
            QString warn = "Это поле должно содержать дату, минимальная дата для установки 1 января 1900 года, максимальная - текущая дата";
            editField = new DateField(columns[i], QDate::currentDate(), d, warn);
            isIgnored.append(false);
        }
        else if(fieldTypes[i] == "timestamp"){
            QString warn = "Это поле должно содержать дату и время, минимальная дата для установки 1 января 1900 года";
            editField = new DateTimeField(columns[i], QDateTime(QDate(2030, 01, 01), QTime(0, 0, 0)), d, warn);
            isIgnored.append(false);
        }
        else if(fieldTypes[i] == "boolean"){
            editField = new BooleanField(d);
            isIgnored.append(false);
        }

        else if(fieldTypes[i] == "id"){
            editField = new EmptyField();
            isIgnored.append(true);
            fields.append(editField);
            continue;
        }

        else if(fieldTypes[i] == "ignore"){
            editField = new EmptyField();
            isIgnored.append(true);
            fields.append(editField);
            continue;
        }

        else{
            editField = new BrokenField();
            isIgnored.append(false);
        }

        fields.append(editField);
        mainLayout->addWidget(editField);
    }

    if(OLD.size() != 0){
        for(int i = 0; i<fields.size(); i++){
            if(fieldsTypes[i] == "boolean"){
                if(OLD[i] == "Да" || OLD[i] == "true")
                    fields[i]->setCurrentValue(true);
                if(OLD[i] == "Нет" || OLD[i] == "false")
                    fields[i]->setCurrentValue(false);
            }
            else{
                fields[i]->setCurrentValue(OLD[i]);
            }
        }
    }
    if(query->queryType == "delete"){
        for(int i = 0; i< fields.size(); i++){
            fields[i]->setUseable(false);
        }
    }


    QPushButton* accept = new QPushButton();
    mainLayout->addWidget(accept);
    accept->setText("Принять");
    connect(accept, &QPushButton::pressed, this, &EditWindow::acceptButton_clicked);
}

EditWindow::~EditWindow()
{
    delete ui;    
}

void EditWindow::parentCloses()
{
    this->close();
}

void EditWindow::acceptButton_clicked()
{
    QSqlDatabase db = QSqlDatabase::database();

    QSqlQuery quer(db);
    quer.prepare(query->queryForm);

    qDebug()<< query->queryType;


    if(query->queryType == "insert"){ //insert

        int a = 0;
        for(int i = 0; i< fields.size(); i++){
            if(!isIgnored[i]){
                QVariant p = fields[i]->getCurrentValue();
                qDebug() << p;
                if(p.canConvert<int>()){
                    if(p.toInt() == -1){
                        return;
                    }
                    if(fieldsTypes[i] == "integer"){
                        p = p.toInt();
                    }
                }
                quer.bindValue(i-a, p);
            }
            else
                a++;
        }
    }
    else if(query->queryType == "update"){ //update
        int a = 0;
        quer.bindValue(0, OLD[0]);
        for(int i = 1; i< fields.size(); i++){
            if(!isIgnored[i]){
                qDebug() << "index: " << i-a;
                QVariant p = fields[i]->getCurrentValue();
                qDebug() << p.toString();
                if(p.canConvert<int>()){
                    if(p.toInt() == -1)
                        return;
                    if(fieldsTypes[i] == "integer" || fieldsTypes[i] == "id"){
                        quer.bindValue(i-a, p.toInt());
                        continue;
                    }
                }
                quer.bindValue(i-a, p);
            }
            else
                a++;

        }

    }
    else if(query->queryType == "delete"){//delete
        quer.bindValue(0, OLD[0].toInt());
    }

    if(quer.exec()){
        quer.next();
        if(quer.value(0).toInt() == -1){
            QMessageBox::information(this, tr("Выполнение операции"), "Операция не выполнена. Получена логическая ошибка в значениях");
        }
        if(quer.value(0).toInt() == -2){
            QMessageBox::information(this, tr("Выполнение операции"), "Операция выполнена. Логическая ошибка добалвения: добавляемых элементов не должно существовать в таблице, либо получена логическая ошибка времени");
        }
        else{
            QMessageBox::information(this, tr("Выполнение операции"), "Ваша операция выполнена.");
            emit success();
            this->close();
        }
    }
    else{

        QString err = quer.lastError().nativeErrorCode();

        if( (err == "23505") || (err == "23505")){
            QMessageBox::critical(this, tr("Ошибка запроса"), "Введенные вами данные уже присудствуют в таблице в одном или нескольких записях");
        }
        else if(err == "42501"){
            QMessageBox::critical(this, tr("Ошибка запроса"), "Ограниченный доступ: запрос не может быть выполнен из-за отсутствия прав доступа");
        }
        else if(err == "42601")
            QMessageBox::critical(this, tr("Системная ошибка"), "Ошибка неправильного запроса (контекст: синтаксис запроса)");
        else if(err == "23502")
            QMessageBox::critical(this, tr("Ошибка запроса"), "Вами введены данные, которые не присудствуют в базе данных.");
        else if(err == "23503")
            QMessageBox::critical(this, tr("Ошибка запроса"), "Этот объект используется другой таблицей. Поэтапно удалите объекты, чтобы выполнить операцию");
        else{
            QMessageBox::critical(this, tr("Ошибка запроса"), "Возникла ошибка при вставке данных. Просим прощения");
        }

        qDebug()<<"  "<<quer.lastError().text();

    }
}
