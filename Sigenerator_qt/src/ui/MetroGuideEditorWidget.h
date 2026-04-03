#pragma once

#include "IProjectEditor.h"
#include "../CoreRegistry.h"

#include <QColor>
#include <QWidget>

class QComboBox;
class QLineEdit;
class TextBoardPreviewWidget;

class MetroGuideEditorWidget : public QWidget, public IProjectEditor {
    Q_OBJECT
public:
    explicit MetroGuideEditorWidget(const CoreRegistry* registry, QWidget* parent = nullptr);

    QString editorId() const override { return "metro_guide"; }
    QString defaultProjectFileName() const override { return "metro_guide_project.json"; }
    void newProject() override;
    bool saveProject(const QString& path, QString* error = nullptr) const override;
    bool loadProject(const QString& path, QString* error = nullptr) override;
    bool exportPng(const QString& path, QString* error = nullptr) const override;

signals:
    void messageRequested(const QString& text);

private:
    void initUi();
    void loadRegistryData();
    void applyCity(const QString& cityId);
    void applyPreview();

private:
    struct MetroGuideDoc {
        QString cityId = "shanghai";
        QString boardTitle = QStringLiteral("出站导向");
        QString directionText = QStringLiteral("2 号口 -> 人民广场");
        QString extraText = QStringLiteral("服务时间 05:45-23:30");
        QColor backgroundColor = QColor("#FFFFFF");
        QColor textColor = QColor("#0B1120");
    };

    const CoreRegistry* m_registry = nullptr;
    MetroGuideDoc m_doc;

    QComboBox* m_cityCombo = nullptr;
    QLineEdit* m_titleEdit = nullptr;
    QLineEdit* m_directionEdit = nullptr;
    QLineEdit* m_extraEdit = nullptr;
    TextBoardPreviewWidget* m_preview = nullptr;
};
