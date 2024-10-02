#include "loginwindow.h"
#include "ui_loginwindow.h"

#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include <QMessageBox>
#include <QDebug>

#include <string>
#include <yaml-cpp/yaml.h>


LoginWindow::LoginWindow(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LoginWindow)
{
    ui->setupUi(this);
    this->setWindowTitle("Вход в систему");
}

LoginWindow::~LoginWindow()
{
    delete ui;
}

void LoginWindow::on_acceptButton_clicked()
{

    if(!QSqlDatabase::drivers().contains("QPSQL")){
        QMessageBox::critical(
                    this,
                    "Unable to load database",
                    "This system needs the QPSQL driver to connect to database"
                    );
        return;
    }

    //TODO: небезопасное поведение кода
    //filePath вообще никак не регулируется

    //это не должно зависеть от пути сборки ни в коем случае
    std::string filePath{"../../../../config.yaml"};

    YAML::Node config = YAML::LoadFile(filePath);

    QString dbName = QString::fromStdString(config["database"]["database_name"].as<std::string>());
    int dbPort = config["database"]["port"].as<int>();
    QString dbHostname = QString::fromStdString(config["database"]["host"].as<std::string>());


    QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
    db.setHostName(dbHostname);
    db.setDatabaseName(dbName);
    db.setPort(dbPort);


    db.setUserName(ui->usernameEdit->text());
    db.setPassword(ui->passwordEdit->text());

    if(db.open())
    {
        emit databaseConnected(db.userName());
        ui->usernameEdit->setText("");
        ui->passwordEdit->setText("");
    }
    else
    {
        ui->usernameEdit->setText("");
        ui->passwordEdit->setText("");
        QMessageBox::critical(this, QObject::tr("Ошибка входа"), "Соединение не установлено: введены неправильные данные для входа или отсутствует подключение к базе данных.\nПроверьте правильность ввода имени пользователя и его пароля.");
        qDebug() << db.lastError();
    }
}

void LoginWindow::on_usernameEdit_returnPressed()
{
    if(ui->usernameEdit->text() == "")
        ui->usernameEdit->setFocus();
    else if(ui->passwordEdit->text() == "")
        ui->passwordEdit->setFocus();
    else
        ui->acceptButton->click();
}


void LoginWindow::on_passwordEdit_returnPressed()
{
    if(ui->usernameEdit->text() == "")
        ui->usernameEdit->setFocus();
    else if(ui->passwordEdit->text() == "")
        ui->passwordEdit->setFocus();
    else
        ui->acceptButton->click();
}
