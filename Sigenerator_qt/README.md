# Sigenerator Qt Refactor

This workspace is the Qt-first rewrite of Sigenerator under `D:/Sigenerator_qt`.

## Architecture (Qt standard)
- `src/domain`: domain models
- `src` core: unified `CoreRegistry`, road template loading, canvas rendering
- `src/ui`: editor widgets and shared preview components
- `MainWindow`: Workbench shell + file/export action routing by active editor

## Implemented features
- Unified registry from:
  - `core_standards` (road + metro guide standards)
  - `core_assets` (city manifests + palettes)
  - `core_canvas_model` (layout/export rules)
- Workbench tabs:
  - 道路指路牌
  - 地铁线路图
  - 地铁导向牌
- Unified file actions (`新建/打开/保存/另存为/导出 PNG`) for all tabs
- Road editor:
  - Load templates from `core_standards/road_gb_5768_2_2022/templates.json`
  - Render SVG board backgrounds
  - Tint place-distance template blue area by selected board color
  - Draw template slot guides and editable text values
  - Save/Open JSON and export PNG
- Metro editor:
  - City-based standard switch from registry
  - Editable line/station/transfer fields
  - Live canvas preview
  - Save/Open JSON and export PNG
- Metro guide editor:
  - City-based standard switch from registry
  - Editable title/direction/extra fields
  - Live canvas preview
  - Save/Open JSON and export PNG

## Build
Use Qt Creator (recommended) or CMake CLI:

```bash
cmake -S . -B build
cmake --build build
./build/SigeneratorQt
```

## Known limits
- Environment here lacks `cmake/qmake`, so this update is not compiled locally in this session.
- Metro and Metro Guide are now functional editors, but still a simplified preview model (not full Flutter parity yet).
- Road editor currently focuses on template/slot text editing, without full node-level drag/resize/undo stack.
