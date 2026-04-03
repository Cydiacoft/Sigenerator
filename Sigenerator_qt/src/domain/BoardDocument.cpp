#include "BoardDocument.h"

BoardDocument BoardDocument::defaults()
{
    BoardDocument d;
    d.templateId = "route_number";
    d.boardColor = QColor("#20308E");
    d.placeName = QStringLiteral("地点名称");
    d.distanceText = QStringLiteral("23 km");
    d.routeClass = QStringLiteral("国家高速");
    d.routeAlias = QStringLiteral("沈海高速");
    d.routeCode = QStringLiteral("GXX");
    return d;
}
