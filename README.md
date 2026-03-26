# Sigenerate

A Flutter desktop app for designing:

- metro / rail transit guide signs
- road route shields and direction signs

The project currently targets **Windows desktop** and focuses on fast visual editing with live preview.

## Features

### Metro guide signs

- Multiple city styles:
  - Shanghai Metro
  - Guangzhou Metro
  - Hong Kong MTR
- Preset metro templates for station name, direction, exit, transfer, and line information
- A metro guide composition mode refactored with reference to [`mercutiojohn/vi-tool`](https://github.com/mercutiojohn/vi-tool)
- Real SVG-based icon elements for:
  - `line`
  - `way`
  - `stn`
  - `oth`
  - `sub`
  - `cls`
  - `clss`
- Horizontal sign composition canvas with:
  - drag-to-insert
  - long-press reorder
  - right-click edit / duplicate / delete
  - undo / redo history

### Road signs

- Road sign editing based on `GB 5768.2-2022`
- Multiple route shield / direction sign templates
- Live template preview and parameter editing

## Tech Stack

- Flutter
- Dart
- Windows desktop
- `flutter_svg`

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── metro_models.dart
│   ├── metro_guide_models.dart
│   ├── templates.dart
│   └── traffic_sign.dart
├── pages/
│   ├── metro_editor_page.dart
│   ├── metro_guide_editor_page.dart
│   ├── road_editor_page.dart
│   └── combined_editor_page.dart
├── painters/
│   ├── metro_painter.dart
│   ├── template_painter.dart
│   └── road_sign_painter.dart
├── utils/
│   ├── export_utils.dart
│   ├── metro_guide_spacing.dart
│   └── metro_guide_svg_utils.dart
└── widgets/
    ├── metro_guide_canvas.dart
    ├── metro_guide_item.dart
    ├── metro_guide_toolbar.dart
    └── metro_guide_toolbar_item.dart

assets/
└── metro_guide/
```

## Getting Started

### Requirements

- Flutter SDK 3.x
- Windows 10/11

### Install dependencies

```bash
flutter pub get
```

### Run

```bash
flutter run -d windows
```

### Build

```bash
flutter build windows --release
```

Build output:

```text
build/windows/x64/runner/Release/
```

## Metro Guide Refactor Notes

The metro guide composition part was refactored to align more closely with the behavior and element system of [`vi-tool`](https://github.com/mercutiojohn/vi-tool):

- imported real SVG guide elements into `assets/metro_guide/`
- replaced placeholder Material icons with SVG rendering
- implemented `vi-tool`-style spacing rules between adjacent guide elements
- added runtime color replacement for color-band based SVG assets
- wired the metro editor's "素材库" tab to the new horizontal composition canvas

## Current Status

Implemented:

- metro template editing
- metro guide composition mode
- road sign template editing
- project save/open flow
- SVG-based metro guide element rendering

Still incomplete or worth improving:

- PNG export flow needs more end-to-end validation
- some metro interactions can be aligned even further with `vi-tool`
- README screenshots are not added yet

## Asset and License Notes

Code in this repository is under the project license.

However, some metro guide SVG assets were imported with reference to the `vi-tool` project. Please review the original repository and its asset/license notes before redistributing those resources commercially or separately from this project:

- [`mercutiojohn/vi-tool`](https://github.com/mercutiojohn/vi-tool)

## References

- [Flutter Desktop Docs](https://docs.flutter.dev/desktop)
- [vi-tool](https://github.com/mercutiojohn/vi-tool)
- [railmapgen.org](https://railmapgen.org)
- [GB 5768.2-2022](https://www.gov.cn/)
