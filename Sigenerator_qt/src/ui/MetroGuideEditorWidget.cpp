#include "MetroGuideEditorWidget.h"

#include "TextBoardPreviewWidget.h"

#include <QComboBox>
#include <QFile>
#include <QHBoxLayout>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QLineEdit>
#include <QVBoxLayout>

MetroGuideEditorWidget::MetroGuideEditorWidget(const CoreRegistry* registry, QWidget* parent)
    : QWidget(parent), m_registry(registry)
{
    initUi();
    loadRegistryData();
    newProject();
}

void MetroGuideEditorWidget::initUi()
{
    auto* root = new QHBoxLayout(this);

    auto* left = new QWidget(this);
    left->setFixedWidth(320);
    auto* leftLayout = new QVBoxLayout(left);

    leftLayout->addWidget(new QLabel(QStringLiteral("城市标准"), left));
    m_cityCombo = new QComboBox(left);
    leftLayout->addWidget(m_cityCombo);

    leftLayout->addWidget(new QLabel(QStringLiteral("主标题"), left));
    m_titleEdit = new QLineEdit(left);
    leftLayout->addWidget(m_titleEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("导向内容"), left));
    m_directionEdit = new QLineEdit(left);
    leftLayout->addWidget(m_directionEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("补充信息"), left));
    m_extraEdit = new QLineEdit(left);
    leftLayout->addWidget(m_extraEdit);

    leftLayout->addStretch(1);

    m_preview = new TextBoardPreviewWidget(this);

    root->addWidget(left);
    root->addWidget(m_preview, 1);

    connect(m_cityCombo, &QComboBox::currentTextChanged, this, [this](const QString& cityId) {
        m_doc.cityId = cityId;
        applyCity(cityId);
        applyPreview();
    });
    connect(m_titleEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.boardTitle = text;
        applyPreview();
    });
    connect(m_directionEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.directionText = text;
        applyPreview();
    });
    connect(m_extraEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.extraText = text;
        applyPreview();
    });
}

void MetroGuideEditorWidget::loadRegistryData()
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

void MetroGuideEditorWidget::applyCity(const QString& cityId)
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

void MetroGuideEditorWidget::applyPreview()
{
    m_preview->setBackgroundColor(m_doc.backgroundColor);
    m_preview->setForegroundColor(m_doc.textColor);
    m_preview->setTitle(m_doc.boardTitle);
    m_preview->setSubtitle(m_doc.directionText);
    m_preview->setFootnote(m_doc.extraText);
}

void MetroGuideEditorWidget::newProject()
{
    m_doc = MetroGuideDoc{};
    applyCity(m_doc.cityId);

    m_cityCombo->blockSignals(true);
    m_titleEdit->blockSignals(true);
    m_directionEdit->blockSignals(true);
    m_extraEdit->blockSignals(true);

    m_cityCombo->setCurrentText(m_doc.cityId);
    m_titleEdit->setText(m_doc.boardTitle);
    m_directionEdit->setText(m_doc.directionText);
    m_extraEdit->setText(m_doc.extraText);

    m_cityCombo->blockSignals(false);
    m_titleEdit->blockSignals(false);
    m_directionEdit->blockSignals(false);
    m_extraEdit->blockSignals(false);

    applyPreview();
}

bool MetroGuideEditorWidget::saveProject(const QString& path, QString* error) const
{
    QJsonObject obj;
    obj.insert("editor", editorId());
    obj.insert("cityId", m_doc.cityId);
    obj.insert("boardTitle", m_doc.boardTitle);
    obj.insert("directionText", m_doc.directionText);
    obj.insert("extraText", m_doc.extraText);
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

bool MetroGuideEditorWidget::loadProject(const QString& path, QString* error)
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
    m_doc.boardTitle = obj.value("boardTitle").toString(m_doc.boardTitle);
    m_doc.directionText = obj.value("directionText").toString(m_doc.directionText);
    m_doc.extraText = obj.value("extraText").toString(m_doc.extraText);
    m_doc.backgroundColor = QColor(obj.value("backgroundColor").toString(m_doc.backgroundColor.name(QColor::HexRgb)));
    m_doc.textColor = QColor(obj.value("textColor").toString(m_doc.textColor.name(QColor::HexRgb)));

    m_cityCombo->blockSignals(true);
    m_titleEdit->blockSignals(true);
    m_directionEdit->blockSignals(true);
    m_extraEdit->blockSignals(true);

    m_cityCombo->setCurrentText(m_doc.cityId);
    m_titleEdit->setText(m_doc.boardTitle);
    m_directionEdit->setText(m_doc.directionText);
    m_extraEdit->setText(m_doc.extraText);

    m_cityCombo->blockSignals(false);
    m_titleEdit->blockSignals(false);
    m_directionEdit->blockSignals(false);
    m_extraEdit->blockSignals(false);

    applyPreview();
    return true;
}

bool MetroGuideEditorWidget::exportPng(const QString& path, QString* error) const
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
