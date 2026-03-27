# Work Plan

## Project

- Name: `Sigenerator`
- Path: `D:\road_creator`
- Stack: Flutter Windows desktop

## Active Goals

- Finish the metro asset alignment work for Shanghai, Guangzhou, and MTR.
- Keep custom metro lines visually closer to the built-in SVG asset style.
- Add a selectable `JR East` starter asset library.
- Keep project save/load, city switching, and toolbar/canvas rendering working together.
- Record the outcome in repo docs and logs, then sync the necessary changes to GitHub.

## Task Board

| ID | Task | Status | Notes |
| --- | --- | --- | --- |
| M1 | Audit metro asset sets and city/model mapping | Completed | Shanghai, Guangzhou, MTR local assets were checked against the current model layer. |
| M2 | Fix city-based SVG loading and cache path issues | Completed | Canvas rendering now receives city context and SVG cache keys are path-based. |
| M3 | Align custom line rendering with SVG-based asset style | Completed | Custom line rendering now uses generated SVG instead of plain container placeholders. |
| M4 | Align Shanghai model coverage with existing asset set | Completed | Shanghai model now covers `line@01-31`. |
| M5 | Align Guangzhou model to real local assets | Completed | Unsupported placeholder lines `18 / 21 / 22` were removed for now. |
| M6 | Align MTR model to real local assets | Completed | Added `mtr11.svg` mapping and synced local colors. |
| M7 | Add JR-style starter asset library | Completed | Added `JR East` city option and starter local SVG set `jr01-jr08`. |
| M8 | Write metro asset audit documentation | Completed | Added `docs/metro_asset_audit.md`. |
| M9 | Refresh work log / plan readability | Completed | `WORK_PLAN.md` and `WORK_LOG.md` were rewritten into clean UTF-8 content. |
| M10 | Run static analysis and prepare GitHub sync | Completed | `flutter analyze --no-pub` is green and the metro/doc batch is ready for GitHub sync. |

## Implementation Notes

### Metro Asset Strategy

- Shanghai remains the main full local baseline.
- Guangzhou and MTR are treated as dedicated city sets, not as Shanghai aliases.
- Unsupported lines are removed from the model until matching local SVG exists.
- Special-line cases such as Guangzhou `GF` / `APM` need a richer metadata model later.

### JR Starter Library

- Purpose: add a local `JR-style` visual option that users can switch to immediately.
- Scope of first batch:
  - Yamanote
  - Chuo Rapid
  - Sobu
  - Keihin-Tohoku
  - Saikyo
  - Yokosuka
  - Keiyo
  - Nambu
- Current status: starter set only, not a complete official JR network pack.

### Verification Targets

- `flutter analyze --no-pub`
- City switch should not leave toolbar assets stuck in loading spinners.
- Toolbar and canvas should render custom lines and built-in city assets consistently.

## Next Step

- Extend first-class metadata for Guangzhou `GF` / `APM`.
- Expand the JR starter library if more regional variants are needed.
- Keep city asset verification going as more local packs are added.
