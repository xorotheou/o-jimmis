# Content Guide

Game content is intentionally isolated under `content/`. The supplied `content/test_environment/world_test.tscn` is an engine verification fixture, not game content.

## Locations

Create an `AdventureLocationDefinition` resource, give it a stable `location_id`, a scene path, and a default spawn id. Author `AdventureSpawnPoint` nodes in the scene. Register definitions with `World.register_location()` and request transitions with `GameEvents.location_requested.emit(location_id, spawn_id)`.

## Walkability and cameras

Location scenes provide `NavigationRegion3D` geometry plus collision layer 1 walkable surfaces. Add an `AdventurePlayerController` with a `NavigationAgent3D`, then attach `AdventureClickToMoveController` in your game scene. Use `AdventureCameraZone` areas with authored `Camera3D` nodes for fixed-camera handoff.

## Adventure data

Register `AdventureItemDefinition`, `AdventureInteractionDefinition`, `AdventureDialogueDefinition`, and `AdventurePuzzleDefinition` resources with their matching services during a game-content bootstrap. Consequences use a deliberately restricted action vocabulary: `set_flag`, `set_variable`, `add_item`, and `remove_item`. This keeps authored dialogue and puzzle data expressive while deterministic services remain authoritative.

A dialogue node has `id`, `text`, optional `conditions`, and `choices`. Each choice has `id`, `text`, optional `conditions`, optional `consequences`, and `next_node_id`; an empty next node ends the conversation. Conditions support `flag` and `has_item` with `id` and optional boolean `value`.
