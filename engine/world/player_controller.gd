class_name AdventurePlayerController
extends CharacterBody3D
## Navigation-agent driven player controller suitable for click-to-move adventures.

signal destination_reached(destination: Vector3)
signal destination_unreachable(destination: Vector3)

@export var movement_speed := 4.0
@export var arrival_distance := 0.15
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var _destination: Vector3
var _has_destination := false

func _ready() -> void:
	add_to_group(&"adventure_player")

func move_to(destination: Vector3) -> void:
	_destination = destination
	_has_destination = true
	navigation_agent.target_position = destination

func cancel_movement() -> void:
	_has_destination = false
	velocity = Vector3.ZERO
	navigation_agent.velocity = Vector3.ZERO

func _physics_process(_delta: float) -> void:
	if not _has_destination:
		return
	if not navigation_agent.is_target_reachable():
		_has_destination = false
		velocity = Vector3.ZERO
		destination_unreachable.emit(_destination)
		return
	if navigation_agent.is_navigation_finished():
		_finish_destination()
		return
	var next_position := navigation_agent.get_next_path_position()
	var flat_target := Vector3(next_position.x, global_position.y, next_position.z)
	var direction := global_position.direction_to(flat_target)
	velocity = direction * movement_speed
	if direction.length_squared() > 0.0001:
		look_at(flat_target, Vector3.UP, true)
	move_and_slide()
	navigation_agent.velocity = velocity
	if global_position.distance_to(_destination) <= arrival_distance:
		_finish_destination()

func _finish_destination() -> void:
	_has_destination = false
	velocity = Vector3.ZERO
	destination_reached.emit(_destination)
