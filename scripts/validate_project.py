#!/usr/bin/env python3
"""Dependency-free structural validation for the Godot engine foundation."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = ["project.godot", "engine/bootstrap.tscn", "README.md", "ARCHITECTURE.md", "DEVELOPMENT.md", "TESTING.md", "CHANGELOG.md", "CONTENT_GUIDE.md", "AI_ARCHITECTURE.md", "content/test_environment/world_test.tscn"]
AUTOLOADS = ["EngineConfig", "GameEvents", "GameState", "Log", "Services", "DebugTools", "World", "Story", "Inventory", "Interaction", "Dialogue", "Puzzles", "Quests", "Npcs", "Clock", "Save", "NpcConversation"]

def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)

for relative in REQUIRED:
    if not (ROOT / relative).is_file():
        fail(f"missing required file: {relative}")
project = (ROOT / "project.godot").read_text()
for autoload in AUTOLOADS:
    if f'{autoload}="*res://' not in project:
        fail(f"missing autoload: {autoload}")
for path in ROOT.rglob("*.gd"):
    content = path.read_text()
    for resource in re.findall(r'res://[^"\s]+', content):
        target = ROOT / resource.removeprefix("res://")
        if resource.endswith(".gd") and not target.exists():
            fail(f"broken resource reference {resource} in {path.relative_to(ROOT)}")
print("Project validation passed.")
