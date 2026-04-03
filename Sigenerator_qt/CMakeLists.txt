cmake_minimum_required(VERSION 3.21)
project(SigeneratorQt LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Svg)

add_executable(SigeneratorQt
    src/main.cpp

    src/TemplateModels.h
    src/CoreRegistry.h
    src/CoreRegistry.cpp
    src/CanvasWidget.h
    src/CanvasWidget.cpp

    src/domain/BoardDocument.h
    src/domain/BoardDocument.cpp

    src/ui/IProjectEditor.h
    src/ui/TextBoardPreviewWidget.h
    src/ui/TextBoardPreviewWidget.cpp
    src/ui/RoadEditorWidget.h
    src/ui/RoadEditorWidget.cpp
    src/ui/MetroEditorWidget.h
    src/ui/MetroEditorWidget.cpp
    src/ui/MetroGuideEditorWidget.h
    src/ui/MetroGuideEditorWidget.cpp

    src/MainWindow.h
    src/MainWindow.cpp
)

target_link_libraries(SigeneratorQt PRIVATE Qt6::Widgets Qt6::Svg)
