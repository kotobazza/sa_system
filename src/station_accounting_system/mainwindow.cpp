#include <QSqlDatabase>
#include <QDebug>

#include "mainwindow.h"
#include "ui_mainwindow.h"

#include "loginwindow.h"
#include "tabledescription.h"
#include "querydescription.h"
#include "tablewindow_customselection.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    this->hide();
    this->setWindowTitle("Система пассажироперевозок");
    logWin = new LoginWindow();
    logWin->show();
    connect(logWin, &LoginWindow::databaseConnected, this, &MainWindow::onlogWin_databaseConnected);
    tableWin = new TableWindow(new TableDescription(false, "none", nullptr), this->ui->place);
    tableWin_custom = new TableWindow_CustomSelection(new TableDescription(false, "none", nullptr), this->ui->place);
    tableWin->hide();
    tableWin_custom->hide();

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::onlogWin_databaseConnected(QString user)
{
    logWin->hide();
    this->show();
    ui->statusbar->showMessage("Добро пожаловать, " + user);
    this->username = user;
    ui->userName->setText(username);
    if(username == "admin" || username == "postgres")
        ui->userName->setStyleSheet("color: red; font-size:18px; font-weight: bold");
}



void MainWindow::on_logOutButton_clicked()
{
    QSqlDatabase::removeDatabase("qt_sql_default_connection");
    ui->statusbar->showMessage("");
    this->close();
    logWin->show();
}

void MainWindow::closeEvent(QCloseEvent *event){
    emit windowCloses();
    event->accept();
}


void MainWindow::on_passengers_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();

    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT passengerId, passport, birthDate, firstName, lastName, middleName FROM passengers",
        "",
        "ID_ignore' 'Паспорт' 'Дата рождения' 'Имя' 'Фамилия' 'Отчество (опционально)"
        );

    QueryDescription* ins = new QueryDescription(
                "insert",
                "Вставить",
                "SELECT * FROM addPassenger(:0, :1, :2, :3, :4)",
                "id text10_passport date text30 text30 text30_optional",
                "ID_ignore' 'Паспорт' 'Дата рождения' 'Имя' 'Фамилия' 'Отчество (опционально)"
                );

    QueryDescription* upd = new QueryDescription(
                "update",
                "Изменить",
                "SELECT * FROM updatePassenger(:id, :0, :1, :2, :3, :4)",
                "id text10_passport date text30 text30 text30_optional",
                "ID_ignore' 'Паспорт' 'Дата рождения' 'Имя' 'Фамилия' 'Отчество (опционально)"
                );

    QueryDescription* del = new QueryDescription(
                "delete",
                "Удалить",
                "SELECT * FROM deletePassenger(:id)",
                "id text10_passport date text30 text30 text30_optional",
                "ID_ignore' 'Паспорт' 'Дата рождения' 'Имя' 'Фамилия' 'Отчество (опционально)"
                );

    TableDescription* descriptor = new TableDescription(false, "Пассажиры", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->passengers->text()+ " создано");
}



void MainWindow::on_tarrifs_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT tarrifId, tarrifName, CASE WHEN tarrifAnimals = TRUE THEN 'Да' WHEN tarrifAnimals = FALSE THEN 'Нет' END AS canAnimals, tarrifCost, tarrifDesc FROM tarrif",
        "",
        "ID_ignore' 'Название тарифа' 'Можно ли с животными' 'Цена' 'Описание"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addTarrif(:0, :1, :2, :3);",
        "id text30 boolean integer text",
        "ID_ignore' 'Название тарифа' 'Можно ли с животными' 'Цена' 'Описание"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateTarrif(:id, :0, :1, :2, :3)",
        "id text30 boolean integer text",
        "ID_ignore' 'Название тарифа' 'Можно ли с животными' 'Цена' 'Описание"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteTarrif(:id)",
        "id text30 boolean integer text",
        "ID_ignore' 'Название тарифа' 'Можно ли с животными' 'Цена' 'Описание"
        );

    TableDescription* descriptor = new TableDescription(false, "Тарифы", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->tarrifs->text()+ " создано");
}


void MainWindow::on_stations_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM stations",
        "",
        "ID_ignore' 'Название станции' 'Состояние станции"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addStation(:0, :1)",
        "id text30 boolean",
        "ID_ignore' 'Название станции' 'Состояние станции(если активная, <да>)"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateStation(:id, :0, :1)",
        "id text30 boolean",
        "ID_ignore' 'Название станции' 'Состояние станции(если активная, <да>)"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteStation(:id)",
        "id text30 boolean",
        "ID_ignore' 'Название станции' 'Состояние станции(если активная, <да>)"
        );

    TableDescription* descriptor = new TableDescription(false, "Станции", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->stations->text()+ " создано");
}


void MainWindow::on_trains_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM trains",
        "",
        "ID_ignore' 'Название поезда"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addTrain(:0)",
        "id text10_train",
        "ID_ignore' 'Название поезда"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateTrain(:id, :0)",
        "id text10_train",
        "ID_ignore' 'Название поезда"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteTrain(:id)",
        "id text10_train",
        "ID_ignore' 'Название поезда"
        );

    TableDescription* descriptor = new TableDescription(false, "Поезда", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->trains->text()+ " создано");
}


void MainWindow::on_routes_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM selectFromRoutesShedule()",
        "",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Поезд"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addRoute(:0, :1, :2, :3, :4, :5)",
        "id text10_route text30 timestamp text30 timestamp text10_train",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Поезд"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateRoute(:0, :1, :2, :3, :4, :5, :6)",
        "id text10_route text30 timestamp text30 timestamp text10_train",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Поезд"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteRoute(:id)",
        "id text10_route text30 timestamp text30 timestamp text10_train",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Поезд"
        );

    TableDescription* descriptor = new TableDescription(false, "Маршруты", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->routes->text()+ " создано");




}


void MainWindow::on_carriages_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM selectFromCarriages()",
        "",
        "ID_ignore' 'Номер вагона' 'Номер поезда' 'Количество мест' 'Зарезервировано' 'Состояние"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addCarriage(:0, :1, :2, :3)",
        "id ignore text10_train integer integer boolean",
        "ID_ignore' 'Номер вагона' 'Номер поезда' 'Количество мест' 'Зарезервировано' 'Состояние(если можно бронировать, то <да>)"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateCarriage(:id, :0, :1, :2, :3, :4)",
        "id text10_carriage text10_train integer integer boolean",
        "ID_ignore' 'Номер вагона' 'Номер поезда' 'Количество мест' 'Зарезервировано' 'Состояние(если можно бронировать, то <да>)"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteCarriage(:id)",
        "id ignore text10_train integer integer boolean",
        "ID_ignore' 'Номер вагона' 'Номер поезда' 'Количество мест' 'Зарезервировано' 'Состояние(если можно бронировать, то <да>)"
        );

    TableDescription* descriptor = new TableDescription(false, "Вагоны", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->carriages->text()+ " создано");
}


void MainWindow::on_tickets_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM selectFromTickets()",
        "",
        "ID_ignore' 'Пассажир (пасспорт)' 'Маршрут' 'Тариф' 'Цена' 'Вагон' 'Дата бронирования"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addTicket(:0, :1, :2, :3, :4)",
        "id text10_passport text10_route text30 ignore text10_carriage date",
        "ID_ignore' 'Пассажир (пасспорт)' 'Маршрут' 'Тариф' 'Цена' 'Вагон' 'Дата бронирования"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateTicket(:id, :0, :1, :2, :3, :4)",
        "id text10_passport text10_route text30 ignore text10_carriage date",
        "ID_ignore' 'Пассажир (пасспорт)' 'Маршрут' 'Тариф' 'Цена' 'Вагон' 'Дата бронирования"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteTicket(:id)",
        "id text10_passport text10_route text30 ignore text10_carriage date",
        "ID_ignore' 'Пассажир (пасспорт)' 'Маршрут' 'Тариф' 'Цена' 'Вагон' 'Дата бронирования"
        );

    TableDescription* descriptor = new TableDescription(false, "Билеты", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->tickets->text()+ " создано");
}


void MainWindow::on_mainShedule_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT FLIGHT_№, FLIGHT_№, DEPRATURE_STATION, DEPARTURE_TIME, ARRIVAL_STATION, ARRIVAL_TIME, TRAIN FROM mainShedule",
        "",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Номер поезда"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Вставить",
        "SELECT * FROM addToMainShedule(:0, :1, :2, :3, :4, :5)",
        "id text10_route text30 timestamp text30 timestamp text10_train",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Номер поезда"
        );

    QueryDescription* upd = new QueryDescription(
        "update",
        "Изменить",
        "SELECT * FROM updateMainShedule(:0, :1, :2, :3, :4, :5, :6)",
        "id text10_route text30 timestamp text30 timestamp text10_train",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Номер поезда"
        );

    QueryDescription* del = new QueryDescription(
        "delete",
        "Удалить",
        "SELECT * FROM deleteFromMainShedule(:id)",
        "id text10_route text30 timestamp text30 timestamp text10_train",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Номер поезда"
        );



    TableDescription* descriptor = new TableDescription(false, "Главное расписание(view)", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->mainShedule->text()+ " создано");
}


void MainWindow::on_carriagesOccupancy_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM getEmptyCarriages()",
        "",
        "Название поезда' 'Номер вагона' 'Зарезервировано мест' 'Всего мест' 'Разница"
        );

    TableDescription* descriptor = new TableDescription(false, "Заполненность вагонов", sel);

    tableWin = new TableWindow(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->carriagesOccupancy->text()+ " создано");
}


void MainWindow::on_averageTicketsCost_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM getAverageTicketCost()",
        "",
        "Пассажир (пасспорт)' 'Номер маршрута' 'Номер вагона' 'Дата бронирования' 'Стоимость по тарифу' 'Итоговая стоимость' 'Средняя цена"
        );

    TableDescription* descriptor = new TableDescription(false, "Средняя цена билетов", sel);

    tableWin = new TableWindow(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->averageTicketsCost->text()+ " создано");
}


void MainWindow::on_activeRoutes_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM getActiveServices()",
        "",
        "Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время приыбтия"
        );

    TableDescription* descriptor = new TableDescription(false, "Активные маршруты", sel);

    tableWin = new TableWindow(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->activeRoutes->text()+ " создано");
}


void MainWindow::on_somestatistics2_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM getCountOfTicketsForEachPassenger()",
        "",
        "Пасспорт' 'Имя' 'Фамилия' 'Отчество (опционально)' 'Кол-во билетов"
        );

    TableDescription* descriptor = new TableDescription(false, "Заказанные билеты", sel);

    tableWin = new TableWindow(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->somestatistics2->text()+ " создано");
}



void MainWindow::on_incompleteTrains_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM getIncompleteTrains()",
        "",
        "Название поезда' 'Неполных вагонов' 'Всего вагонов"
        );

    TableDescription* descriptor = new TableDescription(false, "Наполненность поездов", sel);

    tableWin = new TableWindow(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->incompleteTrains->text()+ " создано");
}


void MainWindow::on_somestatistics1_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
   //! требует отдельное окно, структура которого позволит выгрузить данные из дочерних field сразу в окно таблицы

    QueryDescription* sel = new QueryDescription(
                "select",
                "Выбрать",
                "SELECT * FROM ticketsTypes(:0, :1)",
                "ignore ignore ignore boolean ignore integer",
                "Паспорт' 'Тариф' 'Номер маршрута' 'С животными' 'Количество' 'Больше чем"
                );

    TableDescription* descriptor = new TableDescription(true, "Статистика", sel);
    tableWin_custom = new TableWindow_CustomSelection(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin_custom, &TableWindow_CustomSelection::parentCloses);
    tableWin_custom->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->incompleteTrains->text()+ " создано");


}


void MainWindow::on_superCost_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM superCost()",
        "",
        "Паспорт' 'Имя' 'Фамилия' 'Отчество' 'Итоговая цена' 'Максимальная цена тарифа"
        );

    TableDescription* descriptor = new TableDescription(false, "Наполненность поездов", sel);

    tableWin = new TableWindow(descriptor, this->ui->place);

    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->superCost->text()+ " создано");
}


void MainWindow::on_ticketsIndexing_clicked()
{
    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
   //! требует отдельное окно, структура которого позволит выгрузить данные из дочерних field сразу в окно таблицы

    QueryDescription* sel = new QueryDescription(
                "select",
                "Проиндексировать на проценты",
                "SELECT * FROM indexingTicketsCost(:0)",
                "ignore ignore ignore ignore integer ignore ignore",
                "ID_ignore' 'Пассажир (пасспорт)' 'Маршрут' 'Тариф' 'Цена' 'Вагон' 'Дата бронирования"
                );

    TableDescription* descriptor = new TableDescription(false, "Статистика", sel);
    tableWin_custom = new TableWindow_CustomSelection(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin_custom, &TableWindow_CustomSelection::parentCloses);
    tableWin_custom->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->incompleteTrains->text()+ " создано");
}



void MainWindow::on_createRoute_clicked()
{

    if(!tableWin->isHidden())
        tableWin->hide();
    if(!tableWin_custom->isHidden())
        tableWin_custom->hide();
    QueryDescription* sel = new QueryDescription(
        "select",
        "",
        "SELECT * FROM selectFromRoutesShedule()",
        "",
        "ID_ignore' 'Номер маршрута' 'Станция отправления' 'Время отправления' 'Станция прибытия' 'Время прибытия' 'Поезд"
        );

    QueryDescription* ins = new QueryDescription(
        "insert",
        "Создать полностью новый маршрут",
        "SELECT * FROM transactionCaller(:0, :1, :2, :3, :4, :5)",
        "text10_route text30 text30 text10_train timestamp timestamp",
        "Номер маршрута' 'Станция отправления' 'Станция прибытия' 'Поезд' 'Время отправления' 'Время прибытия"
        );

    QueryDescription* upd = new QueryDescription(
        "",
        "",
        "",
        "",
        ""
        );

    QueryDescription* del = new QueryDescription(
        "",
        "",
        "",
        "",
        ""
        );

    TableDescription* descriptor = new TableDescription(false, "Создание маршрута", sel, ins, upd, del);

    tableWin = new TableWindow(descriptor, this->ui->place);
    connect(this, &MainWindow::windowCloses, tableWin, &TableWindow::parentCloses);
    tableWin->show();
    ui->statusbar->showMessage("Новое окно таблицы " + ui->createRoute->text()+ " создано");
}

