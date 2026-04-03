#pragma once

#include <QMap>
#include <QRectF>
#include <QSizeF>
#include <QString>
#include <QStringList>
#include <QVector>

struct SlotSpec {
    QString id;
    QRectF rect;
};

struct TemplateSpec {
    QString id;
    QString name;
    QSizeF canvasSize;
    QString backgroundSvgAsset;
    QMap<QString, SlotSpec> slots;
};

struct MetroGuideStandard {
    QString cityId;
    QString standard;
    QString version;
    QString primaryFont;
    QString secondaryFont;
    QString backgroundColor;
    QString textColor;
};

struct CityManifest {
    QString cityId;
    QString name;
    QString version;
    QStringList categories;
    QStringList standards;
    QStringList tags;
};

struct PaletteColor {
    QString id;
    QString label;
    QString hex;
};

struct PaletteSpec {
    QString id;
    QString name;
    QVector<PaletteColor> colors;
};

struct CanvasRules {
    int snapTolerance = 0;
    bool showRulers = true;
    bool clampToCanvas = true;
    QStringList exportFormats;
};
