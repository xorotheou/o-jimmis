class_name AdventureClickToMoveController
extends Node
## Converts screen clicks through the active camera into walkable world destinations.

@export var player_path: NodePath
@export var walkable_collision_mask := 1
var player: AdventurePlayerController
var _pending_target: Node

func _ready() -> void:
	player = get_node_or_null(player_path) as AdventurePlayerController
	if player != null:
		if not player.destination_reached.is_connected(_on_destination_reached):
			player.destination_reached.connect(_on_destination_reached)
		if not player.destination_unreachable.is_connected(_on_destination_unreachable):
			player.destination_unreachable.connect(_on_destination_unreachable)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera := get_viewport().get_camera_3d()
		if camera == null or player == null:
			return
		var origin := camera.project_ray_origin(event.position)
		var endpoint := origin + camera.project_ray_normal(event.position) * 1000.0
		var query := PhysicsRayQueryParameters3D.create(origin, endpoint, walkable_collision_mask)
		query.exclude = [player.get_rid()]
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty() and _try_activate_target(hit.get("collider")):
			return
		if not hit.is_empty():
			player.move_to(hit.position)

func _try_activate_target(collider: Variant) -> bool:
	var target := _resolve_target(collider)
	if target == null:
		return false
	if _target_can_activate_from(target, player):
		_pending_target = null
		target.activate()
	else:
		_pending_target = target
		player.move_to(_target_activation_point(target))
	return true

func _resolve_target(collider: Variant) -> Node:
	if collider is Node and collider.get_script() != null and collider.get_script().resource_path.ends_with("world_target.gd"):
		return collider
	if collider is Node and collider.get_parent() != null and collider.get_parent().get_script() != null and collider.get_parent().get_script().resource_path.ends_with("world_target.gd"):
		return collider.get_parent()
	return null

func _target_can_activate_from(target: Node, actor: Node3D) -> bool:
	return target != null and target.has_method("can_activate_from") and bool(target.call("can_activate_from", actor))

func _target_activation_point(target: Node) -> Vector3:
	if target != null and target.has_method("activation_point"):
		return target.call("activation_point")
	return Vector3.ZERO

func _on_destination_reached(_destination: Vector3) -> void:
	if _pending_target != null and player != null and _target_can_activate_from(_pending_target, player):
		var target := _pending_target
		_pending_target = null
		target.activate()

func _on_destination_unreachable(_destination: Vector3) -> void:
	_pending_target = null
