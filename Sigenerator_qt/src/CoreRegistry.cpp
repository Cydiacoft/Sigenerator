#include "CoreRegistry.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace {
QJsonObject readObjectFile(const QString& path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        return {};
    }
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    return doc.isObject() ? doc.object() : QJsonObject{};
}

QStringList toStringList(const QJsonArray& array)
{
    QStringList list;
    for (const QJsonValue& value : array) {
        list.push_back(value.toString());
    }
    return list;
}
} // namespace

bool CoreRegistry::load(const QString& rootPath)
{
    m_roadTemplates.clear();
    m_metroStandards.clear();
    m_cityManifests.clear();
    m_palettes.clear();
    m_canvasRules = CanvasRules{};

    const bool roadOk = loadRoadTemplates(rootPath);
    const bool metroOk = loadMetroStandards(rootPath);
    const bool manifestOk = loadCityManifests(rootPath);
    const bool paletteOk = loadPalettes(rootPath);
    const bool rulesOk = loadCanvasRules(rootPath);

    return roadOk && metroOk && manifestOk && paletteOk && rulesOk;
}

bool CoreRegistry::loadRoadTemplates(const QString& rootPath)
{
    const QJsonObject root = readObjectFile(rootPath + "/core_standards/road_gb_5768_2_2022/templates.json");
    if (root.isEmpty()) {
        return false;
    }

    for (const QJsonValue& value : root.value("templates").toArray()) {
        const QJsonObject obj = value.toObject();
        TemplateSpec spec;
        spec.id = obj.value("id").toString();
        spec.name = obj.value("name").toString();

        const QJsonObject canvas = obj.value("canvasSize").toObject();
        spec.canvasSize = QSizeF(canvas.value("width").toDouble(), canvas.value("height").toDouble());
        spec.backgroundSvgAsset = obj.value("backgroundSvgAsset").toString();

        for (const QJsonValue& slotValue : obj.value("slots").toArray()) {
            const QJsonObject slotObj = slotValue.toObject();
            const QJsonObject rectObj = slotObj.value("rect").toObject();

            SlotSpec slot;
            slot.id = slotObj.value("id").toString();
            slot.rect = QRectF(
                rectObj.value("x").toDouble(),
                rectObj.value("y").toDouble(),
                rectObj.value("width").toDouble(),
                rectObj.value("height").toDouble());

            if (!slot.id.isEmpty()) {
                spec.slots.insert(slot.id, slot);
            }
        }

        if (!spec.id.isEmpty() && spec.canvasSize.width() > 0 && spec.canvasSize.height() > 0) {
            m_roadTemplates.push_back(spec);
        }
    }

    return !m_roadTemplates.isEmpty();
}

bool CoreRegistry::loadMetroStandards(const QString& rootPath)
{
    QDir dir(rootPath + "/core_standards/metro_guide");
    const QFileInfoList files = dir.entryInfoList(QStringList() << "*.json", QDir::Files);
    if (files.isEmpty()) {
        return false;
    }

    for (const QFileInfo& file : files) {
        const QJsonObject obj = readObjectFile(file.absoluteFilePath());
        if (obj.isEmpty()) {
            continue;
        }

        MetroGuideStandard standard;
        standard.cityId = obj.value("cityId").toString();
        standard.standard = obj.value("standard").toString();
        standard.version = obj.value("version").toString();

        const QJsonObject fonts = obj.value("fonts").toObject();
        standard.primaryFont = fonts.value("primary").toString();
        standard.secondaryFont = fonts.value("secondary").toString();

        const QJsonObject colors = obj.value("colors").toObject();
        standard.backgroundColor = colors.value("background").toString("#FFFFFF");
        standard.textColor = colors.value("text").toString("#0B1120");

        if (!standard.cityId.isEmpty()) {
            m_metroStandards.push_back(standard);
        }
    }

    return !m_metroStandards.isEmpty();
}

bool CoreRegistry::loadCityManifests(const QString& rootPath)
{
    QDir root(rootPath + "/core_assets/cities");
    const QFileInfoList dirs = root.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    if (dirs.isEmpty()) {
        return false;
    }

    for (const QFileInfo& cityDir : dirs) {
        const QString manifestPath = cityDir.absoluteFilePath() + "/manifest.json";
        const QJsonObject obj = readObjectFile(manifestPath);
        if (obj.isEmpty()) {
            continue;
        }

        CityManifest manifest;
        manifest.cityId = obj.value("cityId").toString();
        manifest.name = obj.value("name").toString();
        manifest.version = obj.value("version").toString();
        manifest.categories = toStringList(obj.value("categories").toArray());
        manifest.standards = toStringList(obj.value("standards").toArray());
        manifest.tags = toStringList(obj.value("tags").toArray());

        if (!manifest.cityId.isEmpty()) {
            m_cityManifests.push_back(manifest);
        }
    }

    return !m_cityManifests.isEmpty();
}

bool CoreRegistry::loadPalettes(const QString& rootPath)
{
    const QJsonObject root = readObjectFile(rootPath + "/core_assets/palettes/colors.json");
    if (root.isEmpty()) {
        return false;
    }

    for (const QJsonValue& value : root.value("palettes").toArray()) {
        const QJsonObject obj = value.toObject();
        PaletteSpec palette;
        palette.id = obj.value("id").toString();
        palette.name = obj.value("name").toString();

        for (const QJsonValue& colorValue : obj.value("colors").toArray()) {
            const QJsonObject colorObj = colorValue.toObject();
            PaletteColor color;
            color.id = colorObj.value("id").toString();
            color.label = colorObj.value("label").toString();
            color.hex = colorObj.value("hex").toString();
            if (!color.id.isEmpty()) {
                palette.colors.push_back(color);
            }
        }

        if (!palette.id.isEmpty()) {
            m_palettes.push_back(palette);
        }
    }

    return !m_palettes.isEmpty();
}

bool CoreRegistry::loadCanvasRules(const QString& rootPath)
{
    const QJsonObject layout = readObjectFile(rootPath + "/core_canvas_model/rules/layout_rules.json");
    const QJsonObject exportObj = readObjectFile(rootPath + "/core_canvas_model/rules/export_rules.json");
    if (layout.isEmpty() || exportObj.isEmpty()) {
        return false;
    }

    m_canvasRules.snapTolerance = layout.value("guides").toObject().value("snapTolerance").toInt(6);
    m_canvasRules.showRulers = layout.value("guides").toObject().value("showRulers").toBool(true);
    m_canvasRules.clampToCanvas = layout.value("bounds").toObject().value("clampToCanvas").toBool(true);

    const QJsonArray formats = exportObj.value("formats").toArray();
    for (const QJsonValue& value : formats) {
        m_canvasRules.exportFormats.push_back(value.toObject().value("id").toString());
    }

    return !m_canvasRules.exportFormats.isEmpty();
}

TemplateSpec CoreRegistry::roadTemplateById(const QString& id) const
{
    for (const TemplateSpec& templateSpec : m_roadTemplates) {
        if (templateSpec.id == id) {
            return templateSpec;
        }
    }
    return {};
}

MetroGuideStandard CoreRegistry::metroStandardByCity(const QString& cityId) const
{
    for (const MetroGuideStandard& standard : m_metroStandards) {
        if (standard.cityId == cityId) {
            return standard;
        }
    }
    return {};
}

CityManifest CoreRegistry::cityManifestById(const QString& cityId) const
{
    for (const CityManifest& manifest : m_cityManifests) {
        if (manifest.cityId == cityId) {
            return manifest;
        }
    }
    return {};
}

PaletteSpec CoreRegistry::paletteById(const QString& id) const
{
    for (const PaletteSpec& palette : m_palettes) {
        if (palette.id == id) {
            return palette;
        }
    }
    return {};
}
