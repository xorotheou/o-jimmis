extends Node
## Typed engine-wide event boundary. Gameplay systems communicate through named signals.

signal engine_ready
signal state_changed(key: StringName, value: Variant)
signal location_requested(location_id: StringName, spawn_id: StringName)
signal camera_changed(camera_path: NodePath)
signal interaction_requested(target_id: StringName, verb: StringName)
signal debug_command_executed(command: StringName)
