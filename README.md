# Adventure Engine

A reusable **Godot 4.x 3D point-and-click adventure engine**. The engine is game-agnostic: reusable code lives in `engine/`, while every game's authored scenes, resources, assets, dialogue, quests, and puzzles live in `content/`.

## Progress

| Phase | Status | Delivered baseline |
| --- | --- | --- |
| 1 — Foundation | Complete | Bootstrap, configuration, structured logging, events, serializable state, service registry, debug facade, offline validation. |
| 2 — 3D world | Baseline complete | Locations/spawns, navigation-agent player controller, click-to-move raycast, camera zones, interaction points, neutral test environment. |
| 3 — Adventure systems | Baseline complete | Data-driven interactions, inventory and combinations, branching dialogue, story flags/variables/world state, puzzles, quests. |
| 4 — Advanced/NPC/AI | Baseline complete | NPC tiers, relationship and compact memory, game clock, versioned saves, fallback-first non-authoritative conversation facade. |
| Validation game | Pending | Requires a Godot-enabled runtime smoke-test environment before it can be honestly certified. |

## Architecture guarantees

- **Engine ≠ game:** no game-setting identifiers are stored in engine code.
- **Deterministic authority:** story, inventory, puzzles, quests, relationships, time, and saves are owned by engine services.
- **AI is optional presentation:** `NpcConversation` returns cached fallback text and cannot mutate gameplay. Read [AI_ARCHITECTURE.md](AI_ARCHITECTURE.md).
- **Versioned persistence:** the save envelope includes location, state, story, inventory, puzzle, quest, NPC, and time data.

## Quick start

1. Install Godot **4.3** (or a compatible Godot 4.x release) and import `project.godot`.
2. Run the bootstrap scene; add game-owned startup code/resources under `content/`.
3. Register content definitions with their matching autoload service (`World`, `Inventory`, `Interaction`, `Dialogue`, `Puzzles`, `Quests`, or `Npcs`).
4. Run the checks below before committing.

## Validation

```bash
python3 scripts/validate_project.py
python3 -m unittest discover -s tests -v
git diff --check
```

The Python checks verify structural contracts without a Godot executable. A Godot editor/headless smoke test remains required for final runtime certification; see [TESTING.md](TESTING.md).

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — runtime boundaries and service ownership.
- [CONTENT_GUIDE.md](CONTENT_GUIDE.md) — authoring locations and adventure data.
- [DEVELOPMENT.md](DEVELOPMENT.md) — conventions and extension workflow.
- [AI_ARCHITECTURE.md](AI_ARCHITECTURE.md) — safe optional AI integration.
- [TESTING.md](TESTING.md) — automated and runtime validation plan.
- [CHANGELOG.md](CHANGELOG.md) — implementation history.
