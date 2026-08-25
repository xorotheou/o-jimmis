class_name AdventureClickToMoveController
extends Node
## Converts screen clicks through the active camera into walkable world destinations.

@export var player_path: NodePath
@export var walkable_collision_mask := 1
@onready var player: AdventurePlayerController = get_node(player_path)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera := get_viewport().get_camera_3d()
		if camera == null or player == null:
			return
		var origin := camera.project_ray_origin(event.position)
		var endpoint := origin + camera.project_ray_normal(event.position) * 1000.0
		var query := PhysicsRayQueryParameters3D.create(origin, endpoint, walkable_collision_mask)
		query.exclude = [player.get_rid()]
		var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			player.move_to(hit.position)
