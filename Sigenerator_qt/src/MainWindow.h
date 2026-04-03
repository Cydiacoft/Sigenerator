#pragma once

#include "CoreRegistry.h"

#include <QMainWindow>
#include <QMap>

class IProjectEditor;
class QTabWidget;
class RoadEditorWidget;
class MetroEditorWidget;
class MetroGuideEditorWidget;

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(const QString& rootPath, QWidget* parent = nullptr);

private:
    void initUi();
    void initMenus();
    IProjectEditor* activeEditor() const;

    void actionNewProject();
    void actionOpenProject();
    void actionSaveProject();
    void actionSaveAsProject();
    void actionExportPng();

private:
    QString m_rootPath;
    CoreRegistry m_registry;

    QTabWidget* m_tabs = nullptr;
    RoadEditorWidget* m_roadEditor = nullptr;
    MetroEditorWidget* m_metroEditor = nullptr;
    MetroGuideEditorWidget* m_metroGuideEditor = nullptr;

    QMap<QString, QString> m_projectPathByEditor;
};
