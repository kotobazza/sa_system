#ifndef QUERYDESCRIPTION_H
#define QUERYDESCRIPTION_H

#include <QObject>

class QueryDescription : QObject
{
    Q_OBJECT
public:
    QueryDescription(QString, QString buttonText, QString queryForm, QString queryTypes, QString columnsNames);
    QString queryType;             //<text>
    QString buttonText;            //<text>
    QString queryForm ;            //<text/SQL>
    QString queryTypes;            //<text[delimetr: ` `]>    RE определяется по типу
    QString columnsNames;          //<text[delimetr: `' '`]>

    //QString typesWarns;          <text[delimetr: `\n`]>//вставляется при получении RE
    //QString typesDescs          <text[delimetr: '\n']>//вставляется позже
};

#endif // QUERYDESCRIPTION_H
