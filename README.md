# Station Accounting System

Учебный пример системы ведения учета на вокзале. 

## Технологии:
+ Qt5
+ PostgreSQL + PgAdmin
+ Docker 

## Требования
+ Наличие драйвера *QPSQL*
+ Наличие *yaml-cpp*
+ Путь для сборки приложения в QtCreator: `~/src/station_accounting_system/build/Desktop-Debug`
    + или путь такой же глубины
+ В `config.yaml` следует прописать IP-адрес докер-контейнера postgres-sa-system

## Структура базы данных
![Структура базы данных](img/Screenshot_2.png)