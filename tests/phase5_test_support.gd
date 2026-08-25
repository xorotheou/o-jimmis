class_name Phase5TestSupport
extends RefCounted

const CONTENT = preload("res://content/jimmis/bootstrap/jimmis_content.gd")
const PLAYER_SCRIPT = preload("res://engine/world/player_controller.gd")

static func setup_runtime(host_name: String = "Phase5Host") -> Dictionary:
	reset_runtime()
	register_content()
	var tree := Engine.get_main_loop() as SceneTree
	var host := Node3D.new()
	host.name = host_name
	tree.root.add_child(host)
	tree.current_scene = host
	var player := create_player(host, "Jimmy")
	return {"host": host, "player": player}

static func register_content() -> void:
	CONTENT.register_all()

static func reset_runtime() -> void:
	if World.current_location_id != &"":
		World.unload_current_location()
	GameState.reset()
	Story.restore({})
	Inventory.restore({})
	Puzzles.restore({})
	Quests.restore({})
	Npcs.restore({})
	Clock.set_time(480)

static func create_player(host: Node, player_name: String = "Player") -> AdventurePlayerController:
	var player := PLAYER_SCRIPT.new()
	player.name = player_name
	player.position = Vector3(-8.0, 0.5, 0.0)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.28
	shape.height = 1.2
	collision.shape = shape
	player.add_child(collision)
	var agent := NavigationAgent3D.new()
	agent.name = "NavigationAgent3D"
	agent.path_desired_distance = 0.15
	agent.target_desired_distance = 0.15
	player.add_child(agent)
	host.add_child(player)
	return player

static func cleanup_runtime(host: Node) -> void:
	if host != null:
		host.queue_free()

static func has_id(ids: Array, needle: StringName) -> bool:
	for item in ids:
		if StringName(item) == needle:
			return true
	return false
