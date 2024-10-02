#ifndef TABLEDESCRIPTION_H
#define TABLEDESCRIPTION_H

#include <QObject>
#include "querydescription.h"

class TableDescription : QObject
{
    Q_OBJECT

public:
    TableDescription(bool askFirst, QString tableName, QueryDescription* sel, QueryDescription* ins, QueryDescription* upd, QueryDescription* del);
    TableDescription(bool askFirst, QString tableName, QueryDescription* sel);

    /*
        <QString>             <QString>
        buttonText            <text>
        queryForm             <text/SQL>
        queryTypes            <text[delimetr: ` `]>    RE определяется по типу
        columnsNames          <text[delimetr: `' '`]>
        --typesWarns          <text[delimetr: `\n`]>//вставляется при получении RE
        --typesDescs          <text[delimetr: '\n']>//вставляется позже
    */


    QString tableName;
    bool askFirst = false;
    QueryDescription* selectDesc;
    QueryDescription* insertDesc;
    QueryDescription* updateDesc;
    QueryDescription* deleteDesc;

};

#endif // TABLEDESCRIPTION_H
