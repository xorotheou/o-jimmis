extends Node
## Headless runtime smoke test for click-to-move and camera zone switching.

const WORLD_SCENE: PackedScene = preload("res://content/test_environment/world_test.tscn")
const MOVE_TARGET := Vector3(4.0, 0.0, 0.0)
const MAX_PHYSICS_FRAMES := 240

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var world := WORLD_SCENE.instantiate()
	add_child(world)
	await get_tree().process_frame

	var player: AdventurePlayerController = world.get_node("Player")
	var camera_a: Camera3D = world.get_node("CameraA")
	var camera_zone_b: AdventureCameraZone = world.get_node("CameraZoneB")
	var controller := AdventureClickToMoveController.new()
	controller.name = "SmokeClickController"
	controller.player_path = NodePath("../Player")
	world.add_child(controller)
	await get_tree().process_frame

	var click_position: Vector2 = camera_a.unproject_position(MOVE_TARGET)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = click_position
	controller._unhandled_input(click)

	_assert(player.navigation_agent.target_position.distance_to(MOVE_TARGET) < 0.75, "Click-to-move did not set a reachable target near the expected point.")

	camera_zone_b._on_body_entered(player)
	_assert(camera_zone_b.camera.current, "Camera zone B did not make its camera current.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
