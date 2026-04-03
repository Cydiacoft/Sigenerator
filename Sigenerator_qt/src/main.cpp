#include "MainWindow.h"

#include <QApplication>
#include <QDir>
#include <QFile>

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);

    QDir root(QDir::currentPath());
    const QString marker = "core_standards/road_gb_5768_2_2022/templates.json";

    while (!QFile::exists(root.filePath(marker)) && root.cdUp()) {
    }

    MainWindow w(root.absolutePath());
    w.show();

    return app.exec();
}
