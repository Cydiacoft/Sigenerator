#include "RoadEditorWidget.h"

#include <QColorDialog>
#include <QComboBox>
#include <QFile>
#include <QHBoxLayout>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QVBoxLayout>

RoadEditorWidget::RoadEditorWidget(const QString& rootPath, const CoreRegistry* registry, QWidget* parent)
    : QWidget(parent), m_rootPath(rootPath), m_registry(registry)
{
    initUi();
    loadTemplates();
    applyDocumentToUi();
}

void RoadEditorWidget::initUi()
{
    auto* root = new QHBoxLayout(this);

    auto* left = new QWidget(this);
    left->setFixedWidth(320);
    auto* leftLayout = new QVBoxLayout(left);

    leftLayout->addWidget(new QLabel(QStringLiteral("模板"), left));
    m_templateCombo = new QComboBox(left);
    leftLayout->addWidget(m_templateCombo);

    auto* colorBtn = new QPushButton(QStringLiteral("切换背景色"), left);
    leftLayout->addWidget(colorBtn);

    leftLayout->addWidget(new QLabel(QStringLiteral("地点名称"), left));
    m_placeNameEdit = new QLineEdit(left);
    leftLayout->addWidget(m_placeNameEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("距离"), left));
    m_distanceEdit = new QLineEdit(left);
    leftLayout->addWidget(m_distanceEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("道路编号"), left));
    m_routeCodeEdit = new QLineEdit(left);
    leftLayout->addWidget(m_routeCodeEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("道路类别"), left));
    m_routeClassEdit = new QLineEdit(left);
    leftLayout->addWidget(m_routeClassEdit);

    leftLayout->addWidget(new QLabel(QStringLiteral("道路简称"), left));
    m_routeAliasEdit = new QLineEdit(left);
    leftLayout->addWidget(m_routeAliasEdit);
    leftLayout->addStretch(1);

    m_canvas = new CanvasWidget(m_rootPath, this);

    root->addWidget(left);
    root->addWidget(m_canvas, 1);

    connect(m_templateCombo, &QComboBox::currentTextChanged, this, [this](const QString& id) {
        m_doc.templateId = id;
        applyTemplate(id);
        markDirty();
    });
    connect(m_placeNameEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.placeName = text;
        m_canvas->setPlaceName(text);
        markDirty();
    });
    connect(m_distanceEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.distanceText = text;
        m_canvas->setDistanceText(text);
        markDirty();
    });
    connect(m_routeCodeEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.routeCode = text;
        m_canvas->setRouteCode(text);
        markDirty();
    });
    connect(m_routeClassEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.routeClass = text;
        m_canvas->setRouteClass(text);
        markDirty();
    });
    connect(m_routeAliasEdit, &QLineEdit::textChanged, this, [this](const QString& text) {
        m_doc.routeAlias = text;
        m_canvas->setRouteAlias(text);
        markDirty();
    });

    connect(colorBtn, &QPushButton::clicked, this, [this]() {
        const QColor color = QColorDialog::getColor(m_doc.boardColor, this, QStringLiteral("选择背景色"));
        if (color.isValid()) {
            m_doc.boardColor = color;
            m_canvas->setBoardColor(color);
            markDirty();
        }
    });
}

void RoadEditorWidget::loadTemplates()
{
    if (!m_registry || m_registry->roadTemplates().isEmpty()) {
        emit messageRequested(QStringLiteral("道路模板加载失败"));
        return;
    }

    m_templateCombo->blockSignals(true);
    m_templateCombo->clear();
    for (const TemplateSpec& t : m_registry->roadTemplates()) {
        m_templateCombo->addItem(t.id);
    }
    m_templateCombo->blockSignals(false);
}

void RoadEditorWidget::applyTemplate(const QString& id)
{
    if (!m_registry) {
        return;
    }
    const TemplateSpec spec = m_registry->roadTemplateById(id);
    if (spec.id.isEmpty()) {
        return;
    }
    m_canvas->setTemplateSpec(spec);
}

void RoadEditorWidget::applyDocumentToUi()
{
    m_templateCombo->blockSignals(true);
    m_placeNameEdit->blockSignals(true);
    m_distanceEdit->blockSignals(true);
    m_routeClassEdit->blockSignals(true);
    m_routeAliasEdit->blockSignals(true);
    m_routeCodeEdit->blockSignals(true);

    m_templateCombo->setCurrentText(m_doc.templateId);
    m_placeNameEdit->setText(m_doc.placeName);
    m_distanceEdit->setText(m_doc.distanceText);
    m_routeClassEdit->setText(m_doc.routeClass);
    m_routeAliasEdit->setText(m_doc.routeAlias);
    m_routeCodeEdit->setText(m_doc.routeCode);

    m_canvas->setBoardColor(m_doc.boardColor);
    m_canvas->setPlaceName(m_doc.placeName);
    m_canvas->setDistanceText(m_doc.distanceText);
    m_canvas->setRouteClass(m_doc.routeClass);
    m_canvas->setRouteAlias(m_doc.routeAlias);
    m_canvas->setRouteCode(m_doc.routeCode);
    applyTemplate(m_doc.templateId);

    m_templateCombo->blockSignals(false);
    m_placeNameEdit->blockSignals(false);
    m_distanceEdit->blockSignals(false);
    m_routeClassEdit->blockSignals(false);
    m_routeAliasEdit->blockSignals(false);
    m_routeCodeEdit->blockSignals(false);
}

void RoadEditorWidget::markDirty()
{
    if (!m_dirty) {
        m_dirty = true;
        emit projectDirtyChanged(true);
    }
}

void RoadEditorWidget::newProject()
{
    m_doc = BoardDocument::defaults();
    applyDocumentToUi();
    m_dirty = false;
    emit projectDirtyChanged(false);
}

bool RoadEditorWidget::saveProject(const QString& path, QString* error) const
{
    QJsonObject obj;
    obj.insert("editor", editorId());
    obj.insert("templateId", m_doc.templateId);
    obj.insert("boardColor", m_doc.boardColor.name(QColor::HexRgb));
    obj.insert("placeName", m_doc.placeName);
    obj.insert("distanceText", m_doc.distanceText);
    obj.insert("routeClass", m_doc.routeClass);
    obj.insert("routeAlias", m_doc.routeAlias);
    obj.insert("routeCode", m_doc.routeCode);

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

bool RoadEditorWidget::loadProject(const QString& path, QString* error)
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
    BoardDocument d = BoardDocument::defaults();
    d.templateId = obj.value("templateId").toString(d.templateId);
    d.boardColor = QColor(obj.value("boardColor").toString(d.boardColor.name(QColor::HexRgb)));
    d.placeName = obj.value("placeName").toString(d.placeName);
    d.distanceText = obj.value("distanceText").toString(d.distanceText);
    d.routeClass = obj.value("routeClass").toString(d.routeClass);
    d.routeAlias = obj.value("routeAlias").toString(d.routeAlias);
    d.routeCode = obj.value("routeCode").toString(d.routeCode);

    m_doc = d;
    applyDocumentToUi();
    m_dirty = false;
    emit projectDirtyChanged(false);
    return true;
}

bool RoadEditorWidget::exportPng(const QString& path, QString* error) const
{
    const QPixmap pix = m_canvas->grab();
    if (!pix.save(path, "PNG")) {
        if (error) {
            *error = QStringLiteral("PNG 导出失败: ") + path;
        }
        return false;
    }
    return true;
}
