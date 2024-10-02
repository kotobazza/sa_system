#include "loginwindow.h"
#include "ui_loginwindow.h"

#include <QtSql/QSqlDatabase>
#include <QMessageBox>


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
    QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
    db.setDatabaseName("Kursach");
    db.setUserName(ui->usernameEdit->text());
    db.setPassword(ui->passwordEdit->text());

    //db.setUserName("postgres");
    //db.setPassword("postgres");

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
