#include "querydescription.h"


QueryDescription::QueryDescription(QString queryType, QString buttonText, QString queryForm, QString queryTypes, QString columnsNames)
{
    this->buttonText = buttonText;
    this->queryForm = queryForm;
    this->queryTypes = queryTypes;
    this->columnsNames = columnsNames;
    this->queryType = queryType;
}
