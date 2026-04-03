# Core Assets

This module defines a city-aware asset system that is independent from the UI.

Goals
- Keep SVG resources, metadata, color palettes, tags, and city availability separate.
- Make every city an independent manifest that can be extended without touching UI code.
- Make every category a separate capability definition.

Structure
- `cities/<city>/manifest.json`: city-level availability and policy.
- `categories/<category>/abilities.json`: category capability definition.
- `assets/svg`: raw SVG resources.
- `assets/meta`: SVG metadata and mapping.
- `palettes/colors.json`: shared color palettes.
- `tags/tags.json`: shared tag registry.
