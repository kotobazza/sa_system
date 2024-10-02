#include "tabledescription.h"
#include <QDebug>


TableDescription::TableDescription(bool askFirst, QString tableName, QueryDescription *sel, QueryDescription *ins, QueryDescription *upd, QueryDescription *del)
{
    this->askFirst = askFirst;
    this->tableName = tableName;
    this->selectDesc = sel;
    this->insertDesc = ins;
    this->updateDesc = upd;
    this->deleteDesc = del;
}

TableDescription::TableDescription(bool askFirst, QString tableName, QueryDescription* sel)
{
    this->askFirst = askFirst;
    this->tableName = tableName;
    this->selectDesc = sel;
    this->insertDesc = new QueryDescription("", "", "", "", "");
    this->updateDesc = new QueryDescription("", "", "", "", "");
    this->deleteDesc = new QueryDescription("", "", "", "", "");
}
