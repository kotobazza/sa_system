#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include "loginwindow.h"
#include "tablewindow.h"
#include "tablewindow_customselection.h"


QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

signals:
    void windowCloses();

public slots:
    void onlogWin_databaseConnected(QString);

private slots:
    void on_logOutButton_clicked();

    void on_passengers_clicked();

    void on_tarrifs_clicked();

    void on_stations_clicked();

    void on_trains_clicked();

    void on_routes_clicked();

    void on_carriages_clicked();

    void on_tickets_clicked();



    void on_mainShedule_clicked();

    void on_carriagesOccupancy_clicked();

    void on_averageTicketsCost_clicked();

    void on_activeRoutes_clicked();

    void on_somestatistics2_clicked();

    void on_incompleteTrains_clicked();

    void on_somestatistics1_clicked();

    void on_superCost_clicked();


    void on_ticketsIndexing_clicked();


    void on_createRoute_clicked();

private:
    void closeEvent(QCloseEvent *event);
    Ui::MainWindow *ui;
    QString username;
    LoginWindow* logWin;
    TableWindow* tableWin;
    TableWindow_CustomSelection* tableWin_custom;
};
#endif // MAINWINDOW_H
