# Implemented And Working

This file is the living status record for what is currently implemented and working in the engine.
Update it whenever a feature lands, validation changes, or a regression is found.

## Verified Core

- Project bootstrap starts cleanly and registers the core autoload services.
- Structured logging works in-memory, on console, and in the rolling two-run archive.
- `GameState` stores serializable runtime values, publishes state changes, and snapshots/restores deeply.
- `Story` owns flags, variables, and world-state data.
- `Save` writes and restores the versioned save envelope.
- `DebugTools` exposes a read-only inspection surface for runtime state and recent log summaries.

## Verified World Runtime

- The internal test world loads correctly.
- The player controller moves via `NavigationAgent3D`.
- Click-to-move targeting works from the active camera.
- Camera zones switch the current camera.
- Spawn points place the player at authored locations.
- World locations register, load, unload, and swap without breaking the host scene.

## Verified Adventure Systems

- Deterministic actions work for flags, variables, add-item, and remove-item outcomes.
- Inventory supports registration, ownership, inspection, and combination rules.
- Interactions resolve through authored definitions and emit deterministic consequences.
- Dialogue graphs advance through authored choices and close cleanly.
- Puzzles track progress, completion, reset, and reward actions.
- Quests track objectives, complete through deterministic actions, and persist through save/load.

## Verified NPC And Conversation

- NPC profiles register locally.
- Relationship changes are clamped and emitted.
- NPC memory is retained for non-background profiles.
- Fallback NPC conversation works without AI and remains non-authoritative.

## Verified Editor And Diagnostics

- The in-editor launcher opens the test world and smoke scenes.
- The launcher shows the last two run logs without opening JSON files.
- The launcher can filter run logs by text and show errors only.
- The rolling run log keeps only `run_current.json` and `run_previous.json`.

## Validation That Passed

- `python3 scripts/validate_project.py`
- `python3 -m unittest discover -s tests -v`
- Headless smoke scenes for world, save, interaction, inventory, quest, quest save, NPC, location, interaction+inventory, and log rotation
- Headless launcher startup

## Notes

- This file should stay answer-first and current.
- If a feature stops working, remove it from the verified list until it is revalidated.
- If a new subsystem ships, add it here with the exact validation used to confirm it.
