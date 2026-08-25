# Architecture

## Boundary

`engine/` contains reusable runtime code only. `content/` is reserved for a game's scenes, definitions, assets, and authored data. Engine code must never reference a specific game's content path or identifiers.

## Foundation runtime

Godot autoloads own the foundation lifecycle:

- `EngineConfig`: defaults backed by `ProjectSettings` under `adventure_engine/`.
- `GameEvents`: typed signal boundary for cross-system notifications.
- `GameState`: generic serializable key/value state; later domain services will own validation and schemas.
- `Log`: structured in-memory and console logging.
- `Services`: explicit registry for bootstrap-time service discovery.
- `DebugTools`: developer facade for state inspection and safe AI-mode inspection.

`Bootstrap` registers the core services then emits `GameEvents.engine_ready`. Systems should communicate via injected services or event signals; they should not depend on scene-tree searches.

## World runtime

`World` owns location scene lifetime and moves a grouped player to authored `AdventureSpawnPoint` nodes. `AdventurePlayerController` follows paths from `NavigationAgent3D`; click input is converted to a collision-layer-1 ground point by `AdventureClickToMoveController`. Fixed cameras are selected by `AdventureCameraZone`. The reusable internal fixture demonstrates two navigation-connected zones and two spawn points without defining any game setting.

The current Phase 5 game entry point lives in `content/jimmis/bootstrap/`, where authored content registers locations, dialogue, inventory, quests, puzzles, and NPCs against the same generic services. `Save` now persists both the location id and the active spawn id so reloaded games return to the authored entry point.

## Extension direction

Future layers will add world, adventure, save, and AI services behind the same event/state boundaries. Deterministic game services remain authoritative; AI integrations may only produce validated presentation responses.

Game-specific bootstraps remain in `content/<game>/bootstrap/` so the engine can ship with different authored slices without changing reusable engine services.

## Adventure runtime

`Story`, `Inventory`, `Interaction`, `Dialogue`, and `Puzzles` are authoritative deterministic services. Content resources define identifiers, text, conditions, and restricted consequences; `AdventureActionExecutor` is the only generic action interpreter and supports only story flags/variables and inventory mutations. Dialogue presentation may render returned node data, but it cannot directly change game state. This boundary prepares later AI wording layers without granting them gameplay authority.

## Advanced state and AI

`Quests`, `Npcs`, and `Clock` are deterministic services. `Save` serializes their state in a versioned envelope. `NpcConversation` never mutates gameplay state: it returns cached deterministic fallback wording until an explicitly configured adapter is introduced.
