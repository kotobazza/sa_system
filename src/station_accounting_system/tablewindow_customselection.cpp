#include "tablewindow_customselection.h"
#include "ui_tablewindow_customselection.h"

#include <QSqlQuery>
#include <QMessageBox>
#include <QSqlDatabase>
#include <QPushButton>
#include <QDebug>

#include "textfield.h"
#include "datefield.h"
#include "datetimefield.h"
#include "booleanfield.h"
#include "emptyfield.h"
#include "brokenfield.h"


TableWindow_CustomSelection::TableWindow_CustomSelection(TableDescription *descriptor, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::TableWindow_CustomSelection)
{
    ui->setupUi(this);
    setAttribute(Qt::WA_DeleteOnClose);
    mainLayout = new QVBoxLayout(this);
    mainLayout->setAlignment(Qt::AlignTop);
    ui->frame->setLayout(mainLayout);

    if(descriptor->selectDesc == nullptr)
        return;

    this->descripor = descriptor;
    this->setWindowTitle("Таблица '" + descriptor->tableName + "'");

    selectModel = new QSqlQueryModel(this);

    QSqlDatabase db = QSqlDatabase::database();

    QSqlQuery query = QSqlQuery(db);
    query.prepare(descripor->selectDesc->queryForm);

    if(selectModel->lastError().isValid()){
        if(selectModel->lastError().nativeErrorCode() == "42501"){
            QMessageBox::critical(this, tr("Ошибка запроса"), "Ограниченный доступ: запрос не может быть выполнен из-за отсутствия прав доступа");
        }
        else{
            qDebug() << selectModel->lastError().text();
            QMessageBox::critical(this, tr("Ошибка запроса"), "Неизвестная ошибка");

        }

        return;
    }

    int a = 0;

    columns = descripor->selectDesc->columnsNames.split("' '").toVector();




    QVector<QString> fieldTypes = descriptor->selectDesc->queryTypes.split(" ").toVector();
    this->fieldsTypes = fieldTypes;


    assert(fieldTypes.size() == columns.size());

    QString descPreload;

    if(descriptor->selectDesc->queryType == "insert")
        descPreload = "Дайте новое значение полю '";
    else if(descriptor->selectDesc->queryType == "update")
        descPreload = "Измените значение поля '";
    else if(descriptor->selectDesc->queryType == "delete")
        descPreload = "Это поле будет удалено: '";
    else if(descriptor->selectDesc->queryType == "select")
        descPreload = "Использованный параметр выбора:\n'";



    for(int i = 0; i< fieldTypes.size(); i++){
        FieldTemplate* editField;
        QString d = descPreload + columns[i] + "'";

        if(fieldTypes[i] == "text"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }

        }

        else if(fieldTypes[i] == "text10_passport"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }
        }

        else if(fieldTypes[i] == "text30"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }
        }

        else if(fieldTypes[i] == "text30_optional"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }
        }

        else if(fieldTypes[i] == "text10_train"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }
        }
        else if(fieldTypes[i] == "text10_carriage"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }
        }
        else if(fieldTypes[i] == "text10_route"){
            QRegularExpression re("^[А-Яа-я ,.-]{0,255}$");
            QString warn = "Это поле должно содержать прописные и строчные символы кириллицы, а также точку, запаятую, тире и пробел";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, "");
                a++;
                editField->setCurrentValue("");
            }
        }
        else if(fieldTypes[i] == "integer"){
            QRegularExpression re("^[0-9]{1,7}$");
            QString warn = "Это поле должно содержать число, состоящее максимум из 7 цифр";
            editField = new TextField(columns[i], d, warn, re);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, 0);
                a++;
                editField->setCurrentValue(0);
            }
        }

        else if(fieldTypes[i] == "date"){
            QString warn = "Это поле должно содержать дату, минимальная дата для установки 1 января 1900 года";
            editField = new DateField(columns[i], QDate(2030, 01, 01), d, warn);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, QDate::currentDate());
                a++;
                editField->setCurrentValue(0);
            }

        }
        else if(fieldTypes[i] == "birthDate"){
            QString warn = "Это поле должно содержать дату, минимальная дата для установки 1 января 1900 года, максимальная - текущая дата";
            editField = new DateField(columns[i], QDate::currentDate(), d, warn);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, QDate::currentDate());
                a++;
                editField->setCurrentValue(0);
            }
        }
        else if(fieldTypes[i] == "timestamp"){
            QString warn = "Это поле должно содержать дату и время, минимальная дата для установки 1 января 1900 года";
            editField = new DateTimeField(columns[i], QDateTime(QDate(2030, 01, 01), QTime(0, 0, 0)), d, warn);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, QDateTime::currentDateTime());
                a++;
                editField->setCurrentValue(0);
            }
        }
        else if(fieldTypes[i] == "boolean"){
            editField = new BooleanField(d);
            isIgnored.append(false);
            if(descriptor->askFirst){
                query.bindValue(a, false);
                a++;
                editField->setCurrentValue(0);
            }

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

    QPushButton* accept = new QPushButton();
    mainLayout->addWidget(accept);
    accept->setText(descriptor->selectDesc->buttonText);
    connect(accept, &QPushButton::pressed, this, &TableWindow_CustomSelection::selectButtonClicked);


    if(!descriptor->askFirst)
        return;

    if(query.exec()){
            selectModel->setQuery(std::move(query));
            ui->tableView->setModel(selectModel);

            for(int i = 0; i< columns.size(); i++){
                selectModel->setHeaderData(i, Qt::Horizontal, columns[i]);
            }
            QHeaderView* selectHeader = ui->tableView->horizontalHeader();
            for(int i = 0; i< columns.size(); i++){
                selectHeader->setSectionResizeMode(i, QHeaderView::ResizeToContents);
            }


            ui->tableView->setSelectionBehavior(QAbstractItemView::SelectRows);
            ui->tableView->setSelectionMode(QAbstractItemView::SingleSelection);

            if(columns[0] == "ID_ignore")
                ui->tableView->setColumnHidden(0, true);
    }
    else{
        QMessageBox::critical(this, tr("ERROR"), "Error caused by wrong query");
        qDebug() <<query.lastError();
    }

}

TableWindow_CustomSelection::~TableWindow_CustomSelection()
{
    delete ui;
}

void TableWindow_CustomSelection::selectButtonClicked()
{
    QSqlDatabase db = QSqlDatabase::database();

    QSqlQuery quer(db);
    quer.prepare(descripor->selectDesc->queryForm);

    int a = 0;


    for(int i = 0; i< fields.size(); i++){
        if(isIgnored[i] != true){
            QVariant p = fields[i]->getCurrentValue();
            if(p.canConvert<int>()){
                if(p.toInt() == -1)
                    return;
                if(fieldsTypes[i] == "integer"){
                    quer.bindValue(i-a, p.toInt());
                    continue;
                }
            }
            quer.bindValue(i-a, p);
        }
        else
            a++;
    }

    if(quer.exec()){
            QMessageBox::information(this, tr("Выполнение операции"), "Ваша операция выполнена.");
            selectModel->setQuery(std::move(quer));
            ui->tableView->setModel(selectModel);

            for(int i = 0; i< columns.size(); i++){
                selectModel->setHeaderData(i, Qt::Horizontal, columns[i]);
            }
            QHeaderView* selectHeader = ui->tableView->horizontalHeader();
            for(int i = 0; i< columns.size(); i++){
                selectHeader->setSectionResizeMode(i, QHeaderView::ResizeToContents);
            }


            ui->tableView->setSelectionBehavior(QAbstractItemView::SelectRows);
            ui->tableView->setSelectionMode(QAbstractItemView::SingleSelection);

            if(columns[0] == "ID_ignore")
                ui->tableView->setColumnHidden(0, true);
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
            QMessageBox::critical(this, tr("Системная ошибка"), "Ошибка неправильного запроса (контекст: имя функции)");
        else if(err == "23502")
            QMessageBox::critical(this, tr("Ошибка запроса"), "Вами введены данные, которые не присудствуют в базе данных.");
        else{
            QMessageBox::critical(this, tr("Ошибка запроса"), "Возникла ошибка при вставке данных. Просим прощения");
        }

        qDebug()<<"  "<<quer.lastError().text();
        qDebug() << "  "<<quer.lastError().databaseText();
        qDebug()<<"  "<<quer.lastError().nativeErrorCode();
        qDebug() << quer.lastQuery();



    }
}

void TableWindow_CustomSelection::parentCloses()
{
    this->close();
}

void TableWindow_CustomSelection::closeEvent(QCloseEvent *e)
{
    e->accept();
}
