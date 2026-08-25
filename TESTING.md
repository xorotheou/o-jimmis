# Testing

Run these checks from the repository root:

```bash
python3 scripts/validate_project.py
python3 -m unittest discover -s tests -v
```

The validator checks required project files, autoload registration, and script resource references. Contract tests assert the foundation's bootstrap, state-event, snapshot, and engine/content-boundary behavior without needing a Godot installation.

When Godot is installed, also launch `project.godot` and verify the bootstrap log emits `Adventure Engine foundation initialized` without errors.

## Runtime certification checklist

When a Godot 4.x executable is available, run the project headlessly and in the editor, then validate: click-to-move along the internal navigation mesh; an unreachable destination raises the unreachable signal; camera-zone handoff; location load/unload and spawning; the full inspect → collect → talk → use → puzzle → unlock loop; save/load after each state mutation; and AI-disabled fallback dialogue. Capture and resolve every engine error or warning before calling the validation game complete.
