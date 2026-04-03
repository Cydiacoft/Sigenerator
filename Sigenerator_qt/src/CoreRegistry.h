#pragma once

#include "TemplateModels.h"

#include <QMap>
#include <QVector>

class CoreRegistry {
public:
    bool load(const QString& rootPath);

    const QVector<TemplateSpec>& roadTemplates() const { return m_roadTemplates; }
    TemplateSpec roadTemplateById(const QString& id) const;

    const QVector<MetroGuideStandard>& metroStandards() const { return m_metroStandards; }
    MetroGuideStandard metroStandardByCity(const QString& cityId) const;

    const QVector<CityManifest>& cityManifests() const { return m_cityManifests; }
    CityManifest cityManifestById(const QString& cityId) const;

    const QVector<PaletteSpec>& palettes() const { return m_palettes; }
    PaletteSpec paletteById(const QString& id) const;

    const CanvasRules& canvasRules() const { return m_canvasRules; }

private:
    bool loadRoadTemplates(const QString& rootPath);
    bool loadMetroStandards(const QString& rootPath);
    bool loadCityManifests(const QString& rootPath);
    bool loadPalettes(const QString& rootPath);
    bool loadCanvasRules(const QString& rootPath);

private:
    QVector<TemplateSpec> m_roadTemplates;
    QVector<MetroGuideStandard> m_metroStandards;
    QVector<CityManifest> m_cityManifests;
    QVector<PaletteSpec> m_palettes;
    CanvasRules m_canvasRules;
};
