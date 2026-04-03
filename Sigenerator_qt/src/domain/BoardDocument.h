#pragma once

#include <QColor>
#include <QString>

struct BoardDocument {
    QString templateId;
    QColor boardColor;
    QString placeName;
    QString distanceText;
    QString routeClass;
    QString routeAlias;
    QString routeCode;

    static BoardDocument defaults();
};
