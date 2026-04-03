#include "CanvasWidget.h"

#include <QFile>
#include <QPainter>
#include <QRegularExpression>
#include <QSvgRenderer>

CanvasWidget::CanvasWidget(const QString& rootPath, QWidget* parent)
    : QWidget(parent), m_rootPath(rootPath)
{
    setMinimumSize(900, 620);
    setAutoFillBackground(true);
}

void CanvasWidget::setTemplateSpec(const TemplateSpec& spec)
{
    m_template = spec;
    update();
}

void CanvasWidget::setBoardColor(const QColor& color)
{
    m_boardColor = color;
    update();
}

void CanvasWidget::setPlaceName(const QString& value)
{
    m_placeName = value;
    update();
}

void CanvasWidget::setDistanceText(const QString& value)
{
    m_distance = value;
    update();
}

void CanvasWidget::setRouteClass(const QString& value)
{
    m_routeClass = value;
    update();
}

void CanvasWidget::setRouteAlias(const QString& value)
{
    m_routeAlias = value;
    update();
}

void CanvasWidget::setRouteCode(const QString& value)
{
    m_routeCode = value;
    update();
}

void CanvasWidget::paintEvent(QPaintEvent*)
{
    QPainter p(this);
    p.fillRect(rect(), QColor("#0F172A"));
    if (m_template.id.isEmpty()) {
        p.setPen(Qt::white);
        p.drawText(rect(), Qt::AlignCenter, QStringLiteral("未加载模板"));
        return;
    }
    drawBoard(p);
}

void CanvasWidget::drawBoard(QPainter& p)
{
    const qreal margin = 24.0;
    const QRectF area = rect().adjusted(margin, margin, -margin, -margin);
    const qreal sx = area.width() / m_template.canvasSize.width();
    const qreal sy = area.height() / m_template.canvasSize.height();
    const qreal s = qMin(sx, sy);

    const QSizeF boardSize(m_template.canvasSize.width() * s, m_template.canvasSize.height() * s);
    const QPointF topLeft(area.center().x() - boardSize.width() / 2.0,
                          area.center().y() - boardSize.height() / 2.0);
    const QRectF boardRect(topLeft, boardSize);

    p.setRenderHint(QPainter::Antialiasing, true);
    p.fillRect(boardRect, m_boardColor);

    if (!m_template.backgroundSvgAsset.isEmpty()) {
        QString svg = loadSvg(m_template.backgroundSvgAsset);
        if (!svg.isEmpty()) {
            if (m_template.id == "place_distance" || m_template.id == "place_distance_multiline") {
                svg = tintedPlaceDistanceSvg(svg, m_boardColor);
            }
            QSvgRenderer renderer(svg.toUtf8());
            renderer.render(&p, boardRect);
        }
    }

    drawSlots(p, boardRect, s, s);

    p.setPen(QPen(QColor("#EAB308"), 2));
    p.drawRect(boardRect);
}

void CanvasWidget::drawSlots(QPainter& p, const QRectF& boardRect, qreal sx, qreal sy)
{
    auto mapRect = [&](const QRectF& r) {
        return QRectF(
            boardRect.left() + r.left() * sx,
            boardRect.top() + r.top() * sy,
            r.width() * sx,
            r.height() * sy
        );
    };

    p.setPen(QPen(QColor("#22D3EE"), 1));
    p.setBrush(Qt::NoBrush);

    for (const auto& slot : m_template.slots) {
        const QRectF slotRect = mapRect(slot.rect);
        p.drawRect(slotRect);

        p.fillRect(slotRect.adjusted(1, 1, -1, -1), QColor(0, 0, 0, 60));
        p.setPen(Qt::white);

        QString text;
        if (m_template.id.startsWith("place_distance")) {
            if (slot.id == "topCenter") {
                const QStringList lines = m_placeName.split('\n', Qt::SkipEmptyParts);
                text = lines.isEmpty() ? m_placeName : lines.first().trimmed();
            } else if (slot.id == "topRight") {
                text = m_distance;
            } else if (slot.id == "bottomCenter") {
                const QStringList lines = m_placeName.split('\n', Qt::SkipEmptyParts);
                if (lines.size() > 1) {
                    text = lines.mid(1).join(" ").trimmed();
                } else {
                    text = QStringLiteral("多行副标题");
                }
            }
        } else if (m_template.id == "route_number") {
            if (slot.id == "center") {
                text = m_routeCode;
            } else if (slot.id == "topCenter") {
                text = m_routeClass;
            } else if (slot.id == "bottomCenter") {
                text = m_routeAlias;
            }
        } else {
            text = slot.id;
        }

        p.drawText(slotRect.adjusted(6, 4, -6, -4), Qt::AlignLeft | Qt::AlignVCenter, text);
        p.setPen(QPen(QColor("#22D3EE"), 1));
    }
}

QString CanvasWidget::loadSvg(const QString& relativePath) const
{
    QFile f(m_rootPath + "/" + relativePath);
    if (!f.open(QIODevice::ReadOnly)) {
        return {};
    }
    QString data = QString::fromUtf8(f.readAll());
    data.remove(QRegularExpression("<!DOCTYPE[^>]*>"));
    data.remove(QRegularExpression("<metadata[\\s\\S]*?</metadata>", QRegularExpression::CaseInsensitiveOption));
    data.remove(QRegularExpression("\\s+sodipodi:[\\w-]+=\"[^\"]*\""));
    data.remove(QRegularExpression("\\s+inkscape:[\\w-]+=\"[^\"]*\""));
    return data;
}

QString CanvasWidget::tintedPlaceDistanceSvg(const QString& raw, const QColor& color) const
{
    const QString hex = QString("#%1%2%3")
                            .arg(color.red(), 2, 16, QChar('0'))
                            .arg(color.green(), 2, 16, QChar('0'))
                            .arg(color.blue(), 2, 16, QChar('0'))
                            .toUpper();

    QString out = raw;
    out.replace("#253898", hex, Qt::CaseInsensitive);
    out.replace("#253898;", hex + ";", Qt::CaseInsensitive);
    return out;
}
