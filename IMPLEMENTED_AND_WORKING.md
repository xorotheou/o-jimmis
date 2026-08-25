# Implemented And Working

Living status file for the engine. Keep this current whenever something lands, regresses, or is intentionally left incomplete.

## Last Validated

- August 25, 2026

## Working

- Project bootstrap starts cleanly and registers the core autoload services.
- Structured logging works in-memory, on console, and in the rolling two-run archive.
- `GameState` stores serializable runtime values, publishes state changes, and snapshots/restores deeply.
- `Story` owns flags, variables, and world-state data.
- `Save` writes and restores the versioned save envelope.
- `DebugTools` exposes a read-only inspection surface for runtime state and recent log summaries.
- The internal test world loads correctly.
- The player controller moves via `NavigationAgent3D`.
- Click-to-move targeting works from the active camera.
- Camera zones switch the current camera.
- Spawn points place the player at authored locations.
- World locations register, load, unload, and swap without breaking the host scene.
- Deterministic actions work for flags, variables, add-item, and remove-item outcomes.
- Inventory supports registration, ownership, inspection, and combination rules.
- Interactions resolve through authored definitions and emit deterministic consequences.
- Dialogue graphs advance through authored choices and close cleanly.
- Puzzles track progress, completion, reset, and reward actions.
- Quests track objectives, complete through deterministic actions, and persist through save/load.
- NPC profiles register locally.
- Relationship changes are clamped and emitted.
- NPC memory is retained for non-background profiles.
- Fallback NPC conversation works without AI and remains non-authoritative.
- The in-editor launcher opens the test world and smoke scenes.
- The launcher shows the last two run logs without opening JSON files.
- The launcher can filter run logs by text and show errors only.
- The rolling run log keeps only `run_current.json` and `run_previous.json`.

## Partial

- `World.register_location()` stores authored location definitions in `GameState`, which makes runtime state and authored content share the same snapshot boundary.
- `Save._restore()` does not currently verify whether `World.load_location()` succeeded before returning `OK`.
- `AdventureActionExecutor.execute()` applies actions sequentially without rollback, so a later failure can leave earlier mutations applied.
- `Inventory.combine()` can consume the source items before it knows whether the result item can be added.

## Broken

- None currently confirmed by the latest automated validation and smoke tests.

## Validation That Passed

- `python3 scripts/validate_project.py`
- `python3 -m unittest discover -s tests -v`
- Headless smoke scenes for world, save, interaction, inventory, quest, quest save, NPC, location, interaction+inventory, and log rotation
- Headless launcher startup

## Notes

- If a feature stops working, move it out of `Working` until it is revalidated.
- If a partial item is fixed, move it into `Working` and add the validation that proved it.
- If a new issue is discovered, add it to `Partial` or `Broken` with the smallest useful description.
- Refresh the file after a run with:

```bash
python3 scripts/validate_project.py && python3 -m unittest discover -s tests -v && godot --headless --path /home/td/jimmis res://tests/smoke_log_rotation_test.tscn
```
