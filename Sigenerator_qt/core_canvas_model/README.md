# Core Canvas Model

This module defines the editor's data model and rules, fully decoupled from UI.

Goals
- Centralize node types, layout rules, export rules, and undo/redo.
- Keep data-driven rules in JSON so standards can update without UI changes.

Structure
- `model/nodes`: node schemas.
- `model/layout`: layout behaviors (align, snap, grid, guides).
- `rules/layout_rules.json`: data-driven layout constraints.
- `rules/export_rules.json`: export format definitions.
- `history`: command stack for undo/redo.
