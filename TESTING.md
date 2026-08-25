# Testing

Run these checks from the repository root:

```bash
python3 scripts/validate_project.py
python3 -m unittest discover -s tests -v
```

The validator checks required project files, autoload registration, and script resource references. Contract tests assert the foundation's bootstrap, state-event, snapshot, and engine/content-boundary behavior without needing a Godot installation.

When Godot is installed, also launch `project.godot` and verify the bootstrap log emits `Adventure Engine foundation initialized` without errors.

To run the headless smoke test for click-to-move and camera switching:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_world_test.tscn
```

To run the save/load smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_save_test.tscn
```

To run the interaction smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_interaction_test.tscn
```

To run the inventory smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_inventory_test.tscn
```

To run the quest smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_quest_test.tscn
```

To run the quest save/load smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_quest_save_test.tscn
```

To run the NPC smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_npc_test.tscn
```

To run the location-load smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_location_test.tscn
```

To run the interaction+inventory chain smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_interaction_inventory_test.tscn
```

To run the rolling two-run log smoke test:

```bash
godot --headless --path /home/td/jimmis res://tests/smoke_log_rotation_test.tscn
```

The structured logger keeps a compact archive in `user://logs/` as `run_current.json` and `run_previous.json`. The current run is overwritten in place, and the previous run is replaced on the next startup so the last two runs stay available without unbounded growth.
The in-editor test launcher at `engine/dev/test_launcher.tscn` includes a read-only log viewer with a text filter and an `Errors only` toggle so you can inspect the last two runs without opening the JSON files.

## Runtime certification checklist

When a Godot 4.x executable is available, run the project headlessly and in the editor, then validate: click-to-move along the internal navigation mesh; an unreachable destination raises the unreachable signal; camera-zone handoff; location load/unload and spawning; the full inspect → collect → talk → use → puzzle → unlock loop; save/load after each state mutation; and AI-disabled fallback dialogue. Capture and resolve every engine error or warning before calling the validation game complete.
