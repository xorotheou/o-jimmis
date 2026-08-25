class_name JimmisLocationBuilder
extends RefCounted
## Small helper for building placeholder 3D location scenes in code.

const WORLD_TARGET = preload("res://engine/world/world_target.gd")

func add_directional_light(parent: Node, name: String, position: Vector3, rotation_degrees: Vector3 = Vector3(-45.0, 45.0, 0.0)) -> DirectionalLight3D:
	var light := DirectionalLight3D.new()
	light.name = name
	light.position = position
	light.rotation_degrees = rotation_degrees
	parent.add_child(light)
	return light

func add_floor(parent: Node, name: String, size: Vector3, position: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var floor := StaticBody3D.new()
	floor.name = name
	floor.collision_layer = 1
	floor.position = position
	parent.add_child(floor)

	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(size.x, 0.2, size.z)
	shape.position = Vector3.ZERO
	floor.add_child(shape)

	if not OS.has_feature("headless"):
		var mesh_instance := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(size.x, 0.1, size.z)
		mesh_instance.mesh = mesh
		mesh_instance.position = Vector3(0.0, -0.05, 0.0)
		floor.add_child(mesh_instance)
	return floor

func add_navigation_region(parent: Node, name: String, size: Vector3) -> NavigationRegion3D:
	if OS.has_feature("headless"):
		return null
	var region := NavigationRegion3D.new()
	region.name = name
	parent.add_child(region)
	var mesh := NavigationMesh.new()
	var half_x := size.x * 0.5
	var half_z := size.z * 0.5
	mesh.vertices = PackedVector3Array([
		Vector3(-half_x, 0.0, -half_z),
		Vector3(half_x, 0.0, -half_z),
		Vector3(half_x, 0.0, half_z),
		Vector3(-half_x, 0.0, half_z),
	])
	mesh.polygons = [PackedInt32Array([0, 1, 2, 3])]
	region.navigation_mesh = mesh
	return region

func add_spawn(parent: Node, name: String, position: Vector3, spawn_id: StringName) -> AdventureSpawnPoint:
	var spawn := AdventureSpawnPoint.new()
	spawn.name = name
	spawn.position = position
	spawn.spawn_id = spawn_id
	parent.add_child(spawn)
	return spawn

func add_camera(parent: Node, name: String, transform: Transform3D, current := false) -> Camera3D:
	var camera := Camera3D.new()
	camera.name = name
	camera.transform = transform
	camera.current = current
	parent.add_child(camera)
	return camera

func add_camera_zone(parent: Node, name: String, position: Vector3, camera_path: NodePath, size := Vector3(8.0, 3.0, 8.0)) -> AdventureCameraZone:
	var zone := AdventureCameraZone.new()
	zone.name = name
	zone.position = position
	zone.camera_path = camera_path
	zone.collision_layer = 2
	zone.collision_mask = 0
	parent.add_child(zone)

	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	zone.add_child(shape)
	return zone

func add_target(parent: Node, name: String, position: Vector3, size: Vector3, config: Dictionary) -> Node:
	var target := WORLD_TARGET.new()
	target.name = name
	target.position = position
	target.collision_layer = 1
	target.collision_mask = 0
	target.target_kind = config.get("target_kind", WORLD_TARGET.TargetKind.INTERACTION)
	target.target_id = StringName(config.get("target_id", ""))
	target.interaction_verb = StringName(config.get("interaction_verb", "use"))
	target.dialogue_id = StringName(config.get("dialogue_id", ""))
	target.location_id = StringName(config.get("location_id", ""))
	target.spawn_id = StringName(config.get("spawn_id", ""))
	target.activation_distance = float(config.get("activation_distance", 2.0))
	target.conditions = config.get("conditions", [])
	parent.add_child(target)

	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	target.add_child(shape)
	return target

func add_mesh_cube(parent: Node, name: String, position: Vector3, size: Vector3, color: Color = Color(0.8, 0.8, 0.8)) -> MeshInstance3D:
	if not OS.has_feature("headless"):
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = name
		mesh_instance.position = position
		var mesh := BoxMesh.new()
		mesh.size = size
		mesh_instance.mesh = mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		mesh_instance.material_override = material
		parent.add_child(mesh_instance)
		return mesh_instance
	return null
