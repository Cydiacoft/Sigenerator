#pragma once

#include "TemplateModels.h"

#include <QColor>
#include <QWidget>

class CanvasWidget : public QWidget {
    Q_OBJECT
public:
    explicit CanvasWidget(const QString& rootPath, QWidget* parent = nullptr);

    void setTemplateSpec(const TemplateSpec& spec);
    void setBoardColor(const QColor& color);
    void setPlaceName(const QString& value);
    void setDistanceText(const QString& value);
    void setRouteClass(const QString& value);
    void setRouteAlias(const QString& value);
    void setRouteCode(const QString& value);

protected:
    void paintEvent(QPaintEvent* event) override;

private:
    void drawBoard(QPainter& p);
    void drawSlots(QPainter& p, const QRectF& boardRect, qreal sx, qreal sy);
    QString loadSvg(const QString& relativePath) const;
    QString tintedPlaceDistanceSvg(const QString& raw, const QColor& color) const;

private:
    QString m_rootPath;
    TemplateSpec m_template;
    QColor m_boardColor = QColor("#20308E");
    QString m_placeName = QStringLiteral("地点名称");
    QString m_distance = QStringLiteral("23 km");
    QString m_routeClass = QStringLiteral("国家高速");
    QString m_routeAlias = QStringLiteral("沈海高速");
    QString m_routeCode = QStringLiteral("GXX");
};
