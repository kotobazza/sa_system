QT       += core gui sql

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    booleanfield.cpp \
    brokenfield.cpp \
    datefield.cpp \
    datetimefield.cpp \
    editwindow.cpp \
    emptyfield.cpp \
    fieldtemplate.cpp \
    loginwindow.cpp \
    main.cpp \
    mainwindow.cpp \
    querydescription.cpp \
    tabledescription.cpp \
    tablewindow.cpp \
    tablewindow_customselection.cpp \
    textfield.cpp

HEADERS += \
    booleanfield.h \
    brokenfield.h \
    datefield.h \
    datetimefield.h \
    editwindow.h \
    emptyfield.h \
    fieldtemplate.h \
    loginwindow.h \
    mainwindow.h \
    querydescription.h \
    tabledescription.h \
    tablewindow.h \
    tablewindow_customselection.h \
    textfield.h

FORMS += \
    editwindow.ui \
    fieldtemplate.ui \
    loginwindow.ui \
    mainwindow.ui \
    tablewindow.ui \
    tablewindow_customselection.ui


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
