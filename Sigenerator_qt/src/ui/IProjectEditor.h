#pragma once

#include <QString>

class IProjectEditor {
public:
    virtual ~IProjectEditor() = default;

    virtual QString editorId() const = 0;
    virtual QString defaultProjectFileName() const = 0;

    virtual void newProject() = 0;
    virtual bool saveProject(const QString& path, QString* error = nullptr) const = 0;
    virtual bool loadProject(const QString& path, QString* error = nullptr) = 0;
    virtual bool exportPng(const QString& path, QString* error = nullptr) const = 0;
};
