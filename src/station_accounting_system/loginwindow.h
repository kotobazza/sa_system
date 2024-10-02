#ifndef LOGINWINDOW_H
#define LOGINWINDOW_H

#include <QWidget>
#include <QString>

namespace Ui {
class LoginWindow;
}

class LoginWindow : public QWidget
{
    Q_OBJECT

public:
    explicit LoginWindow(QWidget *parent = nullptr);
    ~LoginWindow();

signals:
    void databaseConnected(QString);

private slots:
    void on_acceptButton_clicked();

    void on_usernameEdit_returnPressed();

    void on_passwordEdit_returnPressed();

private:
    Ui::LoginWindow *ui;
};

#endif // LOGINWINDOW_H
