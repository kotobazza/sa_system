#include "tablewindow.h"
#include "ui_tablewindow.h"



#include <QString>
#include <QMessageBox>
#include <QHeaderView>
#include <QPushButton>
#include <QSqlError>

TableWindow::TableWindow(TableDescription* desc, QWidget* parent) :
    QWidget(parent),
    ui(new Ui::TableWindow)
{
    setAttribute(Qt::WA_DeleteOnClose);
    if(desc->selectDesc==nullptr)
        return;



    this->descripor = desc;
    ui->setupUi(this);
    this->setWindowTitle("Таблица '" + desc->tableName + "'");

    selectModel = new QSqlQueryModel(this);

    selectModel->setQuery(descripor->selectDesc->queryForm);
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
    ui->tableView->setModel(selectModel);

    columns =  descripor->selectDesc->columnsNames.split("' '");

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


    if(descripor->insertDesc->buttonText != ""){
        QPushButton* button1 = new QPushButton();
        button1->setText(descripor->insertDesc->buttonText);

        connect(button1, &QPushButton::clicked, this, &TableWindow::button1_clicked);

        button1->setFixedSize(button1->sizeHint());
        ui->horizontalLayout->addWidget(button1);
    }

    if(descripor->updateDesc->buttonText != ""){
        QPushButton* button1 = new QPushButton();
        button1->setText(descripor->updateDesc->buttonText);

        connect(button1, &QPushButton::clicked, this, &TableWindow::button2_clicked);

        button1->setFixedSize(button1->sizeHint());
        ui->horizontalLayout->addWidget(button1);
    }

    if(descripor->deleteDesc->buttonText != ""){
        QPushButton* button1 = new QPushButton();
        button1->setText(descripor->deleteDesc->buttonText);

        connect(button1, &QPushButton::clicked, this, &TableWindow::button3_clicked);

        button1->setFixedSize(button1->sizeHint());
        ui->horizontalLayout->addWidget(button1);
    }

    ui->horizontalLayout->setAlignment(Qt::AlignLeft);

}

TableWindow::~TableWindow()
{
    delete ui;
}

void TableWindow::parentCloses()
{
    emit windowCloses();
    this->close();
}

void TableWindow::editorSuccess()
{
    selectModel->clear();
    selectModel->setQuery(descripor->selectDesc->queryForm);

    ui->tableView->setSelectionBehavior(QAbstractItemView::SelectRows);
    ui->tableView->setSelectionMode(QAbstractItemView::SingleSelection);

    ui->tableView->setColumnHidden(0, true);

    for(int i = 0; i< columns.size(); i++){
        selectModel->setHeaderData(i, Qt::Horizontal, columns[i]);
    }

    QHeaderView* selectHeader = ui->tableView->horizontalHeader();
    for(int i = 0; i< columns.size(); i++){
        selectHeader->setSectionResizeMode(i, QHeaderView::ResizeToContents);
    }
}

void TableWindow::button0_clicked()
{

}

void TableWindow::button1_clicked()
{
    QVector<QString> old;

    editor = new EditWindow(descripor->insertDesc, old);

    connect(editor, &EditWindow::success, this, &TableWindow::editorSuccess);
    connect(this, &TableWindow::windowCloses, editor, &EditWindow::parentCloses);
    editor->show();
}

void TableWindow::button2_clicked()
{
    QItemSelectionModel *selectionModel = ui->tableView->selectionModel();

    if (selectionModel->hasSelection()) {
        QModelIndex currentIndex = selectionModel->currentIndex();

        QVector<QString> old;

        int rowNumber = currentIndex.row();
        QAbstractItemModel *model = ui->tableView->model();

        for(int i = 0; i< columns.size(); i++){
            QModelIndex index = model->index(rowNumber, i);
            old.append(index.data(Qt::DisplayRole).toString());
        }



        editor = new EditWindow(descripor->updateDesc, old);

        connect(editor, &EditWindow::success, this, &TableWindow::editorSuccess);
        connect(this, &TableWindow::windowCloses, editor, &EditWindow::parentCloses);
        editor->show();
    }
    else{
        QMessageBox::warning(this, tr("Не выбрана строка"), "Выберите строку, котороую хотите использовать, с помощью клика ПКМ на одну из ячеек");
    }
}

void TableWindow::button3_clicked()
{
    QItemSelectionModel *selectionModel = ui->tableView->selectionModel();

    if (selectionModel->hasSelection()) {
        QModelIndex currentIndex = selectionModel->currentIndex();

        QVector<QString> old;

        int rowNumber = currentIndex.row();
        QAbstractItemModel *model = ui->tableView->model();

        for(int i = 0; i< columns.size(); i++){
            QModelIndex index = model->index(rowNumber, i);
            old.append(index.data(Qt::DisplayRole).toString());
        }



        editor = new EditWindow(descripor->deleteDesc, old);

        connect(editor, &EditWindow::success, this, &TableWindow::editorSuccess);
        connect(this, &TableWindow::windowCloses, editor, &EditWindow::parentCloses);
        editor->show();
    }
    else{
        QMessageBox::warning(this, tr("Не выбрана строка"), "Выберите строку, котороую хотите использовать, с помощью клика ПКМ на одну из ячеек");
    }
}

void TableWindow::closeEvent(QCloseEvent *e)
{
    emit windowCloses();
    e->accept();
}


