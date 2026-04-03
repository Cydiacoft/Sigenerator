#include "MetroEditorWidget.h"

#include "TextBoardPreviewWidget.h"

#include <QComboBox>
#include <QFile>
#include <QHBoxLayout>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QLineEdit>
#include <QVBoxLayout>

MetroEditorWidget::MetroEditorWidget(const CoreRegistry* registry, QWidget* parent)
    : QWidget(parent), m_registry(registry)
{
    initUi();
    loadRegistryData();
    newProject();
}

void MetroEditorWidget::initUi()
{
    auto* root = new QHBoxLayout(this);

    auto* left = new QWidget(this);
    left->setFixedWidth(320);
    auto* leftLayout = new QVBoxLayout(left);

    leftLayout->addWidget(new QLabel(QStringLiteral("城市标准"), left));
    m_cityCombo = new QComboBox(left);
    leftLayout->addWidget(m_cityCombo);

    leftLayout->addWidget(new QLabel(QStringLiteral("线路名称"), left));
    m_lineEdit = new QLineEdit(left);
    leftLayout->addWidget(m_lineEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("站名"), left));
    m_stationEdit = new QLineEdit(left);
    leftLayout->addWidget(m_stationEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("换乘提示"), left));
    m_hintEdit = new QLineEdit(left);
    leftLayout->addWidget(m_hintEdit);

    leftLayout->addStretch(1);

    m_preview = new TextBoardPreviewWidget(this);

    root->addWidget(left);
    root->addWidget(m_preview, 1);

    connect(m_cityCombo, &QComboBox::currentTextChanged, this, [this](const QString& cityId) {
        m_doc.cityId = cityId;
        applyCity(cityId);
        applyPreview();
    });
    connect(m_lineEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.lineName = text;
        applyPreview();
    });
    connect(m_stationEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.stationName = text;
        applyPreview();
    });
    connect(m_hintEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.transferHint = text;
        applyPreview();
    });
}

void MetroEditorWidget::loadRegistryData()
{
    if (!m_registry) {
        emit messageRequested(QStringLiteral("Registry 未注入"));
        return;
    }

    m_cityCombo->blockSignals(true);
    m_cityCombo->clear();
    for (const CityManifest& manifest : m_registry->cityManifests()) {
        m_cityCombo->addItem(manifest.cityId);
    }
    m_cityCombo->blockSignals(false);
}

void MetroEditorWidget::applyCity(const QString& cityId)
{
    if (!m_registry) {
        return;
    }
    const MetroGuideStandard standard = m_registry->metroStandardByCity(cityId);
    if (!standard.cityId.isEmpty()) {
        m_doc.backgroundColor = QColor(standard.backgroundColor);
        m_doc.textColor = QColor(standard.textColor);
    }
}

void MetroEditorWidget::applyPreview()
{
    m_preview->setBackgroundColor(m_doc.backgroundColor);
    m_preview->setForegroundColor(m_doc.textColor);
    m_preview->setTitle(m_doc.lineName);
    m_preview->setSubtitle(m_doc.stationName);
    m_preview->setFootnote(m_doc.transferHint);
}

void MetroEditorWidget::newProject()
{
    m_doc = MetroDoc{};
    applyCity(m_doc.cityId);

    m_cityCombo->blockSignals(true);
    m_lineEdit->blockSignals(true);
    m_stationEdit->blockSignals(true);
    m_hintEdit->blockSignals(true);

    m_cityCombo->setCurrentText(m_doc.cityId);
    m_lineEdit->setText(m_doc.lineName);
    m_stationEdit->setText(m_doc.stationName);
    m_hintEdit->setText(m_doc.transferHint);

    m_cityCombo->blockSignals(false);
    m_lineEdit->blockSignals(false);
    m_stationEdit->blockSignals(false);
    m_hintEdit->blockSignals(false);

    applyPreview();
}

bool MetroEditorWidget::saveProject(const QString& path, QString* error) const
{
    QJsonObject obj;
    obj.insert("editor", editorId());
    obj.insert("cityId", m_doc.cityId);
    obj.insert("lineName", m_doc.lineName);
    obj.insert("stationName", m_doc.stationName);
    obj.insert("transferHint", m_doc.transferHint);
    obj.insert("backgroundColor", m_doc.backgroundColor.name(QColor::HexRgb));
    obj.insert("textColor", m_doc.textColor.name(QColor::HexRgb));

    QFile f(path);
    if (!f.open(QIODevice::WriteOnly)) {
        if (error) {
            *error = QStringLiteral("无法写入文件: ") + path;
        }
        return false;
    }
    f.write(QJsonDocument(obj).toJson(QJsonDocument::Indented));
    return true;
}

bool MetroEditorWidget::loadProject(const QString& path, QString* error)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) {
        if (error) {
            *error = QStringLiteral("无法读取文件: ") + path;
        }
        return false;
    }

    const QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) {
        if (error) {
            *error = QStringLiteral("项目文件格式错误");
        }
        return false;
    }

    const QJsonObject obj = doc.object();
    m_doc.cityId = obj.value("cityId").toString(m_doc.cityId);
    m_doc.lineName = obj.value("lineName").toString(m_doc.lineName);
    m_doc.stationName = obj.value("stationName").toString(m_doc.stationName);
    m_doc.transferHint = obj.value("transferHint").toString(m_doc.transferHint);
    m_doc.backgroundColor = QColor(obj.value("backgroundColor").toString(m_doc.backgroundColor.name(QColor::HexRgb)));
    m_doc.textColor = QColor(obj.value("textColor").toString(m_doc.textColor.name(QColor::HexRgb)));

    m_cityCombo->blockSignals(true);
    m_lineEdit->blockSignals(true);
    m_stationEdit->blockSignals(true);
    m_hintEdit->blockSignals(true);

    m_cityCombo->setCurrentText(m_doc.cityId);
    m_lineEdit->setText(m_doc.lineName);
    m_stationEdit->setText(m_doc.stationName);
    m_hintEdit->setText(m_doc.transferHint);

    m_cityCombo->blockSignals(false);
    m_lineEdit->blockSignals(false);
    m_stationEdit->blockSignals(false);
    m_hintEdit->blockSignals(false);

    applyPreview();
    return true;
}

bool MetroEditorWidget::exportPng(const QString& path, QString* error) const
{
    const QPixmap pix = m_preview->grab();
    if (!pix.save(path, "PNG")) {
        if (error) {
            *error = QStringLiteral("PNG 导出失败: ") + path;
        }
        return false;
    }
    return true;
}
