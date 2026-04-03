#pragma once

#include "IProjectEditor.h"
#include "../CoreRegistry.h"

#include <QColor>
#include <QWidget>

class QComboBox;
class QLineEdit;
class TextBoardPreviewWidget;

class MetroEditorWidget : public QWidget, public IProjectEditor {
    Q_OBJECT
public:
    explicit MetroEditorWidget(const CoreRegistry* registry, QWidget* parent = nullptr);

    QString editorId() const override { return "metro"; }
    QString defaultProjectFileName() const override { return "metro_project.json"; }
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
    struct MetroDoc {
        QString cityId = "guangzhou";
        QString lineName = QStringLiteral("地铁 1 号线");
        QString stationName = QStringLiteral("体育西路");
        QString transferHint = QStringLiteral("换乘 3 号线");
        QColor backgroundColor = QColor("#FFFFFF");
        QColor textColor = QColor("#0B1120");
    };

    const CoreRegistry* m_registry = nullptr;
    MetroDoc m_doc;

    QComboBox* m_cityCombo = nullptr;
    QLineEdit* m_lineEdit = nullptr;
    QLineEdit* m_stationEdit = nullptr;
    QLineEdit* m_hintEdit = nullptr;
    TextBoardPreviewWidget* m_preview = nullptr;
};
