# Work Log

## Project

- Name: `Sigenerator`
- Path: `D:\road_creator`
- Stack: Flutter Windows desktop

## 2026-03-26

### Metro Guide Refactor

- Reworked the metro guide editor toward the `vi-tool` style asset + canvas workflow.
- Added project save/open/save-as handling for the metro guide editor.
- Introduced custom metro assets into project persistence.
- Added local SVG import support for metro custom assets.
- Added custom metro line creation and editing flow.

### Road Editor Progress

- Switched the road-side material library toward SVG-first rendering.
- Expanded the road sign asset set and aligned it with the ongoing GB 5768 workflow.
- Reworked road sign layout proportions to feel closer to real directional signs.

### Analysis

- Local static analysis reached green state during the refactor stage.

## 2026-03-27

### Metro Asset Audit and Alignment

- Audited the Shanghai, Guangzhou, and MTR metro asset folders against the current model layer.
- Confirmed that Guangzhou and MTR use dedicated local city asset sets instead of Shanghai file reuse.
- Aligned Shanghai model coverage with the current local asset range `line@01-31`.
- Synced local SVG colors back into `MetroLineInfo` for Shanghai, Guangzhou, and MTR.
- Removed Guangzhou placeholder lines `18 / 21 / 22` from the model until matching local SVG exists.
- Added `mtr11.svg` into the MTR model as `High Speed Rail`.

### Metro Rendering Fixes

- Fixed city-aware SVG loading so canvas items no longer try to resolve non-Shanghai assets from the Shanghai root.
- Changed SVG cache behavior to key by resolved asset path instead of file name only.
- Fixed toolbar item type assignment for non-`line@xx` city assets such as `gz*.svg` and `mtr*.svg`.
- Moved custom metro line rendering closer to the built-in asset style by using generated SVG instead of plain container placeholders.
- Reconnected the top city button into a real city selector so Shanghai / Guangzhou / MTR / JR now switch the active material set and background together.
- Rewired the metro guide editor to pass city context into both the toolbar and canvas render path.
- Unified local SVG import into the shared custom-material flow for both `clss` and `oth`.
- Fixed the city-scoped asset resolver so shared root categories such as `way / stn / oth / sub / cls` no longer spin forever by looking in the wrong city folder.
- Switched the built-in material library to a city-native capability model so non-Shanghai cities only expose categories that truly have local asset coverage.
- Added coverage visibility in the top toolbar so the current city's native built-in coverage is explicit instead of implicit.
- Extended local SVG import support so missing native-city categories can be supplemented with real local files instead of waiting on hardcoded packs.

### JR Starter Library

- Added a new selectable city/style option: `JR East`.
- Added starter JR-style metro assets:
  - `jr01.svg`
  - `jr02.svg`
  - `jr03.svg`
  - `jr04.svg`
  - `jr05.svg`
  - `jr06.svg`
  - `jr07.svg`
  - `jr08.svg`
- Added matching JR model entries and guide-material mapping.
- Added JR-aware SVG city inference for the asset loader.

### Documentation

- Added `docs/metro_asset_audit.md` to track:
  - current city asset coverage
  - color extraction results
  - known model/asset gaps
  - next actions
- Rewrote `WORK_PLAN.md` into a clean executable task board.
- Rewrote `WORK_LOG.md` into a clean UTF-8 log.

### Verification

- `flutter analyze --no-pub`
- Result: `No issues found!`

### Remaining Follow-up

- Guangzhou / MTR / JR still need real local SVG packs for `way / stn / oth / sub / cls` if they are meant to reach full native coverage.
- Guangzhou special lines `GF` / `APM` still need a richer metadata model if they are meant to be first-class line entries.
- MTR filename-to-line-name mapping still needs a stronger source manifest if full confidence is required.
- JR is currently a starter library, not yet a full network pack.

### Road Editor Refactor

- Replaced the old four-direction preview workflow with a single editable road board canvas.
- Added direct in-place text editing by double-clicking text nodes on the board.
- Added editable white-box templates and scenic bordered templates that can hold text directly.
- Added replaceable center graphic nodes for crossroad, T junction, roundabout, Y junction, and skewed intersections.
- Introduced slot-based board layout so the reference nine-area sign composition can be snapped back into place.
- Added template-rule snapping that restores slot position, width, height, font size, white-box behavior, and scenic border behavior together.
- Moved the road board layout spec into a dedicated data model file:
  - `lib/models/road_board_template.dart`
- Added a dedicated road board document model:
  - `lib/models/road_board_document.dart`
- Added direct board export actions from the new editor toolbar:
  - save current board state as JSON
  - export current board canvas as PNG
- Wrapped the new editable board canvas in a dedicated capture boundary so exports follow the same single-board source of truth.
- Reframed the road editor back into a generator-style workflow closer to the original reference page instead of a pure freeform board designer.
- Added a top-down generator layout:
  - format settings
  - intersection name section
  - four-direction data matrix
  - visual editing workspace
  - generated multi-direction previews
- Moved road-name editing onto the board itself so the key text fields can be edited visually instead of only through table inputs.
- Kept white and scenic plates as draggable board elements, and added true plate fill support so scenic plates can use a brown fill instead of only a border simulation.
- Changed the road board baseline back to a horizontal guide-board aspect ratio and constrained drag movement to stay inside the board.
- Rebuilt the road editor page into a clean UTF-8 Chinese interface after the previous page text became corrupted by encoding issues.
- Kept the generator-style workflow while restoring direct visual editing of road-name content on the board.
- Refined the horizontal road-board template again toward a GB-style guide sign proportion:
  - larger horizontal board ratio
  - tighter outer margins
  - more balanced top / side / bottom slot sizes
  - larger central intersection graphic area
- Added a more sign-like board render treatment:
  - outer and inner double white borders
  - tighter internal safety margin
  - flatter guide-sign corner radius
  - more restrained center-line stroke weight
- Tightened the default white and scenic sub-plate sizes so newly added plates behave more like attached guide-sign information plates instead of generic cards.
- Localized the in-canvas editing affordances in the road board widget, including edit hints and action buttons.
- Restyled the road editor layout closer to the metro editor structure with a dark three-panel workspace instead of the earlier flat generator page.
- Added Word-like horizontal text alignment options for road-board text elements:
  - align left
  - center
  - align right
- Enlarged the draggable hit area around road-board elements so text and sub-plates are much easier to grab and move.
- Added resizable left and right side panels in the road editor so the canvas no longer gets squeezed by fixed sidebars.
- Added a dedicated canvas zoom slider for the road board preview area so wide signs can be inspected without changing window size.
- Fixed drag-follow behavior under canvas zoom by scaling pointer movement back into board coordinates.
- Restored free board-viewport movement in the central workspace so the entire sign can be panned inside the editor instead of only being scaled.
- Corrected the road-board baseline aspect ratio back toward the reference crossroad sign layout after the previous template pass became too tall.
- Added road-project file actions in the toolbar:
  - new project
  - open project
  - save project
  - save project as
- Extended the road board document model to persist the full editor state:
  - scene colors and intersection shape
  - four-direction source data
  - active direction
  - junction transliteration
  - all board nodes by direction
- Added desktop keyboard shortcuts for road-board elements:
  - `Ctrl+C`
  - `Ctrl+V`
  - `Ctrl+D`
  - `Delete`
- Added a right-click canvas context menu for road-board elements with copy, paste, duplicate, layer order, text alignment, and delete actions.
- Restored visible Chinese labels across the main road-editor toolbar, side panels, selection panel, and in-canvas edit dialog where mojibake had leaked in.
- Added a quick `重置视图` action for the road-board workspace so panned canvases can snap back to a predictable working position.
- Kept the project at a fully green analyzer state after the road editor refactor.
- Reworked the ruler stack toward a data-driven viewport model:
  - added `lib/models/road_canvas_viewport.dart` as the single source for zoom/pan-to-world conversion
  - added `lib/widgets/road_ruler_strip.dart` to render PS-style horizontal/vertical rulers from viewport data
  - rulers now track real board pan offset and show negative/positive coordinates instead of static fixed ticks
- Added a top-left ruler origin corner marker to make the board origin relationship explicit.
- Replaced focus-fragile shortcut wiring with global key handling in the road editor:
  - `Ctrl+C`
  - `Ctrl+V`
  - `Ctrl+D`
  - `Delete`
  - `Esc`
- Kept text-edit fields safe by skipping global shortcut interception while `EditableText` has focus.

## 2026-03-29

### Road Editor Stability and PS-Style Interaction

- Fixed the previously broken-string risk in the road editor by restoring the page to a clean parseable state and re-running analyzer verification.
- Added repository-level encoding guard files:
  - `.editorconfig` with UTF-8 + LF defaults
  - `.gitattributes` text normalization
- Added `scripts/check_utf8_and_analyze.ps1` for strict UTF-8 decode checks plus `flutter analyze --no-pub`.
- Replaced old static ruler painters with the new data-driven ruler strip stack:
  - `lib/models/road_canvas_viewport.dart`
  - `lib/widgets/road_ruler_strip.dart`
- Added draggable guides from rulers and in-canvas guide overlays:
  - horizontal guide drag from left ruler
  - vertical guide drag from top ruler
  - draft guide preview during drag
  - one-click clear guides action
- Added guide snap logic for selected non-graphic elements (left/top/center alignment snap).
- Tightened node bounds behavior:
  - dynamic X/Y range based on current node size and board size
  - width/height clamping to board bounds
  - auto-clamp after size changes
- Added numeric direct input beside property sliders (custom value entry + clamp).
- Fixed text element interaction hit-box sizing so text selection/drag boxes no longer feel oversized.
- Replaced known mojibake leftovers in road-editor UI strings (plate defaults and export toasts).

### Verification

- `flutter analyze --no-pub lib/pages/road_editor_page.dart lib/widgets/road_sign_canvas.dart lib/models/road_canvas_viewport.dart lib/widgets/road_ruler_strip.dart`
- Result: `No issues found!`

### Road Editor Generator-Style Expansion (GB)

- Added a generator-style control block in the road editor left panel to match the requested workflow:
  - top mode tabs (`综合标志 / 地点距离 / 服务区距离 / 道路编号 / 自由编辑`)
  - sign-type selector chips (left/right/straight/lane-guide variants)
  - GB board color presets (`绿色 / 蓝色 / 棕色`)
  - board opacity control (`0.5 ~ 1.0`)
  - utility toggles (`出口距离` and `顶部信息栏`) with on-canvas node injection/removal
  - text-row editing tools (move/copy/type/main-text/english-line/add-row/add-element/delete-row)
- Added `应用 GB 标准预设` action:
  - normalizes core board colors and text styles
  - constrains center graphic sizes
  - enforces stronger white-on-color / color-on-white contrast defaults
- Added bottom quick actions in canvas workspace:
  - `下载到本地` (PNG export)
  - `复制到剪贴板` (copies exported PNG path)
- Kept analyzer clean after this integration.

### Road Editor Scenario Layer + Ruler Alignment Fix

- Clarified and implemented the two-layer model in editor behavior:
  - base layer: crossroad visual board editing
  - scenario layer: mode-driven fine-grained controls (`综合标志 / 地点距离 / 服务区距离 / 道路编号 / 自由编辑`)
- Linked scenario tabs to real canvas behavior (not only visual tab switching):
  - mode selection now drives utility blocks and sign-type defaults
  - sign type now maps into center graphic behavior (`crossroad / skewLeft / skewRight`)
- Fixed severe ruler/guide misalignment by unifying coordinate origins:
  - introduced content-origin offsets into viewport transform
  - aligned ruler conversion, guide dragging, and guide overlay drawing to the same board-content origin
  - set `InteractiveViewer` alignment to `Alignment.topLeft` to remove implicit offset drift
- Preserved analyzer-green state after integration.

### Scenario Integration Follow-up

- Upgraded scenario tabs from single-direction toggles to whole-board-set presets:
  - mode selection now applies across all four directions
  - sign type mapping now updates center graphic for every direction board
- Added scenario-specific content presets:
  - `地点距离`: exit-distance utility defaults
  - `服务区距离`: service-area styled bottom plates + utility info
  - `道路编号`: top route-number style utility info
- Ensured color changes (`绿色/蓝色/棕色`) keep current scenario preset behavior instead of resetting into an unrelated state.

### Scenario-Specific Template Switch (Requested Behavior)

- Refactored road template model to support multiple independent board templates instead of a single crossroad template:
  - `standard_crossroad`
  - `place_distance`
  - `service_distance`
  - `route_number`
  - `free_compose`
- Added template registry and lookup in `lib/models/road_board_template.dart` (`all`, `byId`, per-template id constants).
- Updated road editor runtime to use an active template id rather than a fixed compile-time template:
  - scene tab click now switches template id first, then applies scenario preset
  - board rebuild now uses the currently selected scenario template
  - project open now restores `templateId` and maps it back to the correct scenario tab
- This makes “十字路口” one concrete template case under the scenario system, not the global default for every mode.

### Reference-Driven Scenario Editor Expansion

- Updated scenario tabs to align with the referenced workflows:
  - `综合标志`
  - `地点距离`
  - `服务区距离`
  - `服务区和停车区预告`
  - `道路编号和命名编号`
  - `自由编辑模式`
- Added dedicated scenario editing forms in the left panel for:
  - place-distance name + km + english line
  - service-distance/service-advance name + km + english line + icon toggles
  - route-number class + main code + branch code + alias
- Added independent scenario template id `service_advance` and wired it into tab-template mapping.
- Implemented template-specific board builders for:
  - place distance
  - service distance / service advance
  - route number
  - free compose (crossroad base)
- All scenario inputs now rebuild their corresponding template output board directly (data-driven).

### Remove Crossroad Mode (Requested)

- Removed crossroad as a standalone scenario entry from the top scenario tabs.
- Merged the original crossroad-oriented control set into `自由编辑模式` only.
- Hid the old bottom crossroad configuration block in non-free modes, so it no longer appears under other scenario editors.
- Updated default/new-project scenario to `自由编辑模式` and mapped legacy `standard_crossroad` project files to free-edit tab on open.

### Top Bar Layout Switcher (VS Code Style)

- Replaced old panel toggle buttons in the top toolbar with a VS Code style layout switcher.
- Added four layout presets:
  - left + center
  - center only
  - center + right
  - left + center + right
- Added visual active-state highlight and linked each preset to left/right panel visibility.

## 2026-04-01

### Ruler Layout and Alignment Fix

- Fixed vertical ruler container clipping and visual misalignment:
  - Replaced the `Row` wrapper in `_buildCanvasPanel` with a strict `Column(Row, Row)` grid structure.
  - Added a `36x28` top-left corner spacer so the vertical ruler origin matches the exact Y-offset as the `InteractiveViewer` content.
  - Removed the hardcoded constraint on the vertical ruler and used `CrossAxisAlignment.stretch`, allowing it to expand gracefully into the underlying remaining height without mid-screen truncation.
- Verified that viewport coordinate mappings (`worldFromScreen` and `screenFromWorld`) properly intercept viewport offsets and translate faithfully into visual guide drags.
- Guaranteed `flutter analyze --no-pub` remains green under `lib/pages/road_editor_page.dart`.
