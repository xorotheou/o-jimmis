# Changelog

## Unreleased

### Added
- Phase 5 Jimmis vertical slice: content bootstrap, five connected locations, five NPCs, branching dialogue, inventory combinations, quest/puzzle progression, developer HUD, and vertical-slice regression scenes.
- Phase 4 advanced baseline: quests/objectives, NPC tiers with relationship and compact memory state, deterministic clock, versioned saves, and a cached fallback-first NPC conversation facade.
- Phase 3 deterministic adventure baseline: story state, inventory definitions and ownership, data-driven interactions, branching dialogue graphs, and puzzle progress/completion services.
- Phase 2 world baseline: data-driven location transitions, spawning, navigation-agent movement, click-to-move, camera zones, interaction points, and a neutral internal 3D fixture.
- Phase 1 reusable Godot foundation: bootstrap, configuration, logging, events, game state, service registry, and debugging facade.
- Engine/content directory boundary, offline structural validation, contract tests, and developer documentation.

### Fixed
- Save restore now preserves the active location spawn id so reloaded games return to the intended entry point.
- Save restore now restores puzzle data and location requests through public service restore APIs rather than mutating service internals.
- Player navigation now reports unreachable destinations instead of treating them as successful arrivals.
