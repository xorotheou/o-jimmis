extends Node
## Headless runtime smoke test for registering and loading a location.

var _failures: Array[String] = []
var _loaded_seen := false
var _unloaded_seen := false

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var host := Node3D.new()
	host.name = "LocationSmokeHost"
	get_tree().root.add_child(host)
	get_tree().current_scene = host

	var player := AdventurePlayerController.new()
	var navigation_agent := NavigationAgent3D.new()
	navigation_agent.name = "NavigationAgent3D"
	player.add_child(navigation_agent)
	player.name = "SmokePlayer"
	player.position = Vector3(-9.0, 0.5, 0.0)
	host.add_child(player)

	var location_a := AdventureLocationDefinition.new()
	location_a.location_id = &"smoke_location_a"
	location_a.scene_path = "res://content/test_environment/world_test.tscn"
	location_a.default_spawn_id = &"area_a"

	var location_b := AdventureLocationDefinition.new()
	location_b.location_id = &"smoke_location_b"
	location_b.scene_path = "res://content/test_environment/world_test.tscn"
	location_b.default_spawn_id = &"area_b"

	World.location_loaded.connect(_on_location_loaded)
	World.location_unloaded.connect(_on_location_unloaded)
	World.register_location(location_a)
	World.register_location(location_b)

	_assert(World.load_location(&"smoke_location_a", &"area_a"), "Initial location load failed.")
	_assert(_loaded_seen, "Location loaded signal did not fire for the first location.")
	_loaded_seen = false
	_assert(not _unloaded_seen, "First load should not unload a prior location.")

	_assert(World.load_location(&"smoke_location_b", &"area_b"), "Second location load failed.")
	_assert(_loaded_seen, "Location loaded signal did not fire for the second location.")
	_assert(_unloaded_seen, "Location unloaded signal did not fire when replacing the first location.")
	_assert(World.current_location_id == &"smoke_location_b", "Current location id did not update.")
	_assert(player.global_position.distance_to(Vector3(7.0, 0.5, 0.0)) < 0.25, "Player did not spawn at area_b.")
	_assert(get_tree().current_scene == host, "Host scene should remain current.")

	World.unload_current_location()
	host.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

func _on_location_loaded(_location_id: StringName) -> void:
	_loaded_seen = true

func _on_location_unloaded(_location_id: StringName) -> void:
	_unloaded_seen = true
