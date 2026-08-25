extends Node3D

@onready var builder := preload("res://content/jimmis/locations/location_builder.gd").new()
const WorldTarget := preload("res://engine/world/world_target.gd")

func _ready() -> void:
	builder.add_directional_light(self, "ChurchLight", Vector3(0.0, 10.0, 0.0))
	builder.add_floor(self, "ChurchYardFloor", Vector3(20.0, 0.2, 16.0))
	builder.add_navigation_region(self, "ChurchNavigation", Vector3(20.0, 3.0, 16.0))

	builder.add_mesh_cube(self, "ChurchFront", Vector3(0.0, 2.2, -5.0), Vector3(8.0, 4.4, 4.0), Color(0.88, 0.86, 0.8))
	builder.add_mesh_cube(self, "BellTower", Vector3(6.0, 3.0, -5.5), Vector3(2.0, 6.0, 2.0), Color(0.78, 0.76, 0.72))
	builder.add_mesh_cube(self, "Steps", Vector3(0.0, 0.3, -2.0), Vector3(4.0, 0.6, 2.5), Color(0.6, 0.6, 0.58))

	builder.add_spawn(self, "ChurchExteriorEntry", Vector3(0.0, 0.5, 6.5), &"church_entry")

	var camera_a := builder.add_camera(self, "CameraChurchWide", Transform3D(Basis(Vector3.UP, deg_to_rad(10.0)), Vector3(0.0, 9.0, 12.0)), true)
	var camera_b := builder.add_camera(self, "CameraChurchDoor", Transform3D(Basis(Vector3.UP, deg_to_rad(-15.0)), Vector3(0.0, 5.5, 5.5)))
	builder.add_camera_zone(self, "ChurchZoneWide", Vector3(0.0, 1.0, 2.0), camera_a.get_path(), Vector3(12.0, 3.0, 10.0))
	builder.add_camera_zone(self, "ChurchZoneDoor", Vector3(0.0, 1.0, -1.0), camera_b.get_path(), Vector3(8.0, 3.0, 6.0))

	builder.add_target(self, "ChurchReturn", Vector3(0.0, 1.0, 8.0), Vector3(3.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"village_square",
		"spawn_id": &"square_east",
	})
	builder.add_target(self, "ChurchDoorLocked", Vector3(0.0, 1.0, -3.5), Vector3(3.0, 4.0, 1.5), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"church_door_locked",
		"interaction_verb": &"look",
	})
	builder.add_target(self, "ChurchEnter", Vector3(0.0, 1.0, -4.8), Vector3(2.5, 4.0, 1.5), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"church_interior",
		"spawn_id": &"church_interior_entry",
		"conditions": [{"type": "flag", "id": "church_access_unlocked", "value": true}],
	})
	builder.add_target(self, "NicolaDialogue", Vector3(-4.0, 1.0, 1.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"nicola_dialogue",
	})
	builder.add_target(self, "PriestDialogue", Vector3(4.0, 1.0, 1.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"priest_dialogue",
	})
