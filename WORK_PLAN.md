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
- Convert the metro material library to a city-native asset model instead of silent fallback reuse.
- Allow local SVG supplementation for any metro material category that lacks native city assets.
- Refactor the road editor from painter-driven direction cards into a single data-driven board editor.
- Make the road board directly editable in place and closer to the GB 5768 sign layout workflow.
- Give the new road board editor a usable output path through JSON persistence and PNG export.
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
| R1 | Replace old four-direction road preview with a single editable board | Completed | The road editor now uses one central editable board canvas as the source of truth. |
| R2 | Add direct in-place editing for road board items | Completed | Text, white boxes, scenic boxes, and center graphics can now be edited on the board. |
| R3 | Move road layout rules into a template model | Completed | Added `lib/models/road_board_template.dart` and switched snap behavior to template slots. |
| R4 | Add output support for the new road board model | Completed | Added JSON save and PNG export for the current editable road board. |
| R5 | Re-align road editor workflow to the generator-style reference page | Completed | The page now uses top settings, a four-direction matrix, a visual editing workspace, and generated previews instead of a pure freeform editor. |
| R6 | Move road-name editing onto the board while keeping sub-plates draggable | Completed | Road names now edit directly on the selected board, while white and scenic plates remain movable elements. |
| R7 | Restore clean Chinese road-editor UI and refine GB-style slot proportions | Completed | The page is back to a clean Chinese interface and the horizontal board template was tightened toward GB-style proportions. |
| R8 | Do a consolidated GB-style visual refinement pass | Completed | Added double border treatment, tighter margins, refined slot sizing, and smaller sub-plate defaults in one pass. |
| R9 | Align road-editor workspace style and text layout controls with the metro editor UX | Completed | Added a dark three-panel workspace, horizontal text alignment controls, and larger drag hit areas. |
| R10 | Improve road-editor viewport usability | Completed | Added resizable side panels, canvas zoom, and drag-follow correction under scaling. |
| R11 | Restore road-board viewport control and desktop editing workflow | Completed | Added board panning, project file open/save/save-as, keyboard shortcuts, and canvas right-click actions. |
| R12 | Upgrade ruler and viewport to data-driven editor state | Completed | Added viewport model, PS-style pan-linked ruler strips, global shortcut handling, and analyzer-clean integration. |
| R13 | Add guide drag/snap and harden editor string/encoding stability | Completed | Added ruler-driven guides + snap, dynamic property ranges/custom numeric input, UTF-8 guardrails, and analyzer-clean stabilization. |
| R14 | Fix vertical ruler alignment and container clipping | Completed | Restructured ruler container grid with a 36x28 corner spacer and vertical stretch, preventing vertical clipping during zoom/pan mapping. |

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
- The road editor should keep a green analyzer state while the new board model replaces the old painter workflow.
- The road editor should stay close to the reference generator flow while moving key text editing onto the visual board.
- Continue refining slot sizes, text heights, and white/scenic plate constraints toward GB 5768.2-2022 without breaking the generator-style workflow.

## Next Step

- Expand Guangzhou beyond `line / clss` by importing and organizing real local SVG for `way / stn / oth / sub / cls`.
- Extend first-class metadata for Guangzhou `GF` / `APM`.
- Expand the JR starter library if more regional variants are needed.
- Keep city asset verification going as more local packs are added.
