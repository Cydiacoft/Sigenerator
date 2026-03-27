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

- Guangzhou special lines `GF` / `APM` still need a richer metadata model if they are meant to be first-class line entries.
- MTR filename-to-line-name mapping still needs a stronger source manifest if full confidence is required.
- JR is currently a starter library, not yet a full network pack.
