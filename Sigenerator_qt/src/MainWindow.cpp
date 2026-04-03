#include "MainWindow.h"

#include "ui/IProjectEditor.h"
#include "ui/MetroEditorWidget.h"
#include "ui/MetroGuideEditorWidget.h"
#include "ui/RoadEditorWidget.h"

#include <QFileDialog>
#include <QMenu>
#include <QMenuBar>
#include <QStatusBar>
#include <QTabWidget>

MainWindow::MainWindow(const QString& rootPath, QWidget* parent)
    : QMainWindow(parent), m_rootPath(rootPath)
{
    setWindowTitle(QStringLiteral("Sigenerator Qt Workbench"));
    resize(1440, 900);

    if (!m_registry.load(m_rootPath)) {
        statusBar()->showMessage(QStringLiteral("核心资源加载不完整，请检查 core_standards/core_assets/core_canvas_model"), 8000);
    }

    initUi();
    initMenus();
}

void MainWindow::initUi()
{
    m_tabs = new QTabWidget(this);
    setCentralWidget(m_tabs);

    m_roadEditor = new RoadEditorWidget(m_rootPath, &m_registry, this);
    m_metroEditor = new MetroEditorWidget(&m_registry, this);
    m_metroGuideEditor = new MetroGuideEditorWidget(&m_registry, this);

    m_tabs->addTab(m_roadEditor, QStringLiteral("道路指路牌"));
    m_tabs->addTab(m_metroEditor, QStringLiteral("地铁线路图"));
    m_tabs->addTab(m_metroGuideEditor, QStringLiteral("地铁导向牌"));

    connect(m_roadEditor, &RoadEditorWidget::messageRequested, this, [this](const QString& text) {
        statusBar()->showMessage(text, 3000);
    });
    connect(m_metroEditor, &MetroEditorWidget::messageRequested, this, [this](const QString& text) {
        statusBar()->showMessage(text, 3000);
    });
    connect(m_metroGuideEditor, &MetroGuideEditorWidget::messageRequested, this, [this](const QString& text) {
        statusBar()->showMessage(text, 3000);
    });
}

void MainWindow::initMenus()
{
    auto* fileMenu = menuBar()->addMenu(QStringLiteral("文件"));

    auto* actNew = fileMenu->addAction(QStringLiteral("新建项目"));
    auto* actOpen = fileMenu->addAction(QStringLiteral("打开项目"));
    auto* actSave = fileMenu->addAction(QStringLiteral("保存项目"));
    auto* actSaveAs = fileMenu->addAction(QStringLiteral("项目另存为"));
    fileMenu->addSeparator();
    auto* actExport = fileMenu->addAction(QStringLiteral("导出 PNG"));

    connect(actNew, &QAction::triggered, this, &MainWindow::actionNewProject);
    connect(actOpen, &QAction::triggered, this, &MainWindow::actionOpenProject);
    connect(actSave, &QAction::triggered, this, &MainWindow::actionSaveProject);
    connect(actSaveAs, &QAction::triggered, this, &MainWindow::actionSaveAsProject);
    connect(actExport, &QAction::triggered, this, &MainWindow::actionExportPng);
}

IProjectEditor* MainWindow::activeEditor() const
{
    return dynamic_cast<IProjectEditor*>(m_tabs->currentWidget());
}

void MainWindow::actionNewProject()
{
    IProjectEditor* editor = activeEditor();
    if (!editor) {
        return;
    }
    editor->newProject();
    m_projectPathByEditor.remove(editor->editorId());
    statusBar()->showMessage(QStringLiteral("已新建项目"), 3000);
}

void MainWindow::actionOpenProject()
{
    IProjectEditor* editor = activeEditor();
    if (!editor) {
        return;
    }

    const QString path = QFileDialog::getOpenFileName(
        this,
        QStringLiteral("打开项目"),
        QString(),
        QStringLiteral("JSON (*.json)"));
    if (path.isEmpty()) {
        return;
    }

    QString err;
    if (!editor->loadProject(path, &err)) {
        statusBar()->showMessage(err, 5000);
        return;
    }
    m_projectPathByEditor[editor->editorId()] = path;
    statusBar()->showMessage(QStringLiteral("项目已打开"), 3000);
}

void MainWindow::actionSaveProject()
{
    IProjectEditor* editor = activeEditor();
    if (!editor) {
        return;
    }

    const QString existingPath = m_projectPathByEditor.value(editor->editorId());
    if (existingPath.isEmpty()) {
        actionSaveAsProject();
        return;
    }

    QString err;
    if (!editor->saveProject(existingPath, &err)) {
        statusBar()->showMessage(err, 5000);
        return;
    }
    statusBar()->showMessage(QStringLiteral("项目已保存"), 3000);
}

void MainWindow::actionSaveAsProject()
{
    IProjectEditor* editor = activeEditor();
    if (!editor) {
        return;
    }

    const QString path = QFileDialog::getSaveFileName(
        this,
        QStringLiteral("项目另存为"),
        editor->defaultProjectFileName(),
        QStringLiteral("JSON (*.json)"));
    if (path.isEmpty()) {
        return;
    }

    QString err;
    if (!editor->saveProject(path, &err)) {
        statusBar()->showMessage(err, 5000);
        return;
    }
    m_projectPathByEditor[editor->editorId()] = path;
    statusBar()->showMessage(QStringLiteral("项目已保存"), 3000);
}

void MainWindow::actionExportPng()
{
    IProjectEditor* editor = activeEditor();
    if (!editor) {
        return;
    }

    const QString path = QFileDialog::getSaveFileName(
        this,
        QStringLiteral("导出 PNG"),
        editor->editorId() + "_preview.png",
        QStringLiteral("PNG (*.png)"));
    if (path.isEmpty()) {
        return;
    }

    QString err;
    if (!editor->exportPng(path, &err)) {
        statusBar()->showMessage(err, 5000);
        return;
    }
    statusBar()->showMessage(QStringLiteral("PNG 导出完成"), 3000);
}
