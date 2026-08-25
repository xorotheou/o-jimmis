extends Node
## Owns location scene transitions and player spawning. Location content is never hard-coded.

signal location_loaded(location_id: StringName)
signal location_unloaded(location_id: StringName)

var current_location_id: StringName
var _current_location: Node

func register_location(definition: AdventureLocationDefinition) -> void:
	assert(definition.is_valid_definition(), "Location definitions need an id and an existing scene")
	GameState.set_value(&"world/location_definitions/%s" % definition.location_id, definition)

func load_location(location_id: StringName, spawn_id: StringName = &"") -> bool:
	var definition: AdventureLocationDefinition = GameState.get_value(&"world/location_definitions/%s" % location_id)
	if definition == null:
		Log.error("world", "Unknown location requested", {"location_id": location_id})
		return false
	var packed_scene := load(definition.scene_path) as PackedScene
	if packed_scene == null:
		Log.error("world", "Location scene could not load", {"scene_path": definition.scene_path})
		return false
	unload_current_location()
	_current_location = packed_scene.instantiate()
	get_tree().current_scene.add_child(_current_location)
	current_location_id = location_id
	var resolved_spawn := spawn_id if not spawn_id.is_empty() else definition.default_spawn_id
	_spawn_player(resolved_spawn)
	location_loaded.emit(location_id)
	return true

func unload_current_location() -> void:
	if _current_location == null:
		return
	var previous_id := current_location_id
	_current_location.queue_free()
	_current_location = null
	current_location_id = &""
	location_unloaded.emit(previous_id)

func _spawn_player(spawn_id: StringName) -> void:
	var player := get_tree().get_first_node_in_group(&"adventure_player") as Node3D
	if player == null:
		Log.warning("world", "No player found for location spawn")
		return
	for spawn: Node in _current_location.find_children("*", "AdventureSpawnPoint", true, false):
		if spawn.spawn_id == spawn_id:
			player.global_transform = spawn.global_transform
			return
	Log.warning("world", "Spawn point not found", {"spawn_id": spawn_id, "location_id": current_location_id})
