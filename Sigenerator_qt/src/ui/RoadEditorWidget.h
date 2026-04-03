#pragma once

#include "IProjectEditor.h"
#include "../CanvasWidget.h"
#include "../CoreRegistry.h"
#include "../domain/BoardDocument.h"

#include <QWidget>

class QComboBox;
class QLineEdit;

class RoadEditorWidget : public QWidget, public IProjectEditor {
    Q_OBJECT
public:
    explicit RoadEditorWidget(const QString& rootPath, const CoreRegistry* registry, QWidget* parent = nullptr);

    QString editorId() const override { return "road"; }
    QString defaultProjectFileName() const override { return "road_project.json"; }
    void newProject() override;
    bool saveProject(const QString& path, QString* error = nullptr) const override;
    bool loadProject(const QString& path, QString* error = nullptr) override;
    bool exportPng(const QString& path, QString* error = nullptr) const override;

signals:
    void projectDirtyChanged(bool dirty);
    void messageRequested(const QString& text);

private:
    void initUi();
    void loadTemplates();
    void applyTemplate(const QString& id);
    void applyDocumentToUi();
    void markDirty();

private:
    QString m_rootPath;
    const CoreRegistry* m_registry = nullptr;
    BoardDocument m_doc = BoardDocument::defaults();
    bool m_dirty = false;

    QComboBox* m_templateCombo = nullptr;
    QLineEdit* m_placeNameEdit = nullptr;
    QLineEdit* m_distanceEdit = nullptr;
    QLineEdit* m_routeClassEdit = nullptr;
    QLineEdit* m_routeAliasEdit = nullptr;
    QLineEdit* m_routeCodeEdit = nullptr;
    CanvasWidget* m_canvas = nullptr;
};
