extends Node3D

@onready var builder := preload("res://content/jimmis/locations/location_builder.gd").new()
const WorldTarget := preload("res://engine/world/world_target.gd")

func _ready() -> void:
	builder.add_directional_light(self, "InteriorLight", Vector3(0.0, 8.0, 0.0))
	builder.add_floor(self, "ChurchInteriorFloor", Vector3(16.0, 0.2, 12.0))
	builder.add_navigation_region(self, "ChurchInteriorNavigation", Vector3(16.0, 3.0, 12.0))

	builder.add_mesh_cube(self, "Altar", Vector3(0.0, 1.0, -4.0), Vector3(4.0, 2.0, 1.5), Color(0.84, 0.82, 0.76))
	builder.add_mesh_cube(self, "StoreroomDoor", Vector3(5.0, 1.0, 2.5), Vector3(2.0, 2.4, 0.8), Color(0.56, 0.5, 0.42))
	builder.add_mesh_cube(self, "Bench", Vector3(-4.0, 0.6, 2.0), Vector3(2.0, 1.2, 0.6), Color(0.48, 0.34, 0.26))

	builder.add_spawn(self, "ChurchInteriorEntry", Vector3(0.0, 0.5, 5.0), &"church_interior_entry")

	var camera_a := builder.add_camera(self, "CameraInteriorWide", Transform3D(Basis(Vector3.UP, deg_to_rad(15.0)), Vector3(0.0, 7.0, 8.0)), true)
	var camera_b := builder.add_camera(self, "CameraInteriorStoreroom", Transform3D(Basis(Vector3.UP, deg_to_rad(-20.0)), Vector3(5.0, 5.5, 3.0)))
	builder.add_camera_zone(self, "InteriorZoneWide", Vector3(0.0, 1.0, 1.0), camera_a.get_path(), Vector3(10.0, 3.0, 8.0))
	builder.add_camera_zone(self, "InteriorZoneStoreroom", Vector3(4.5, 1.0, 2.0), camera_b.get_path(), Vector3(6.0, 3.0, 6.0))

	builder.add_target(self, "ChurchExit", Vector3(0.0, 1.0, 6.5), Vector3(3.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"church_exterior",
		"spawn_id": &"church_entry",
	})
	builder.add_target(self, "StoreroomClue", Vector3(5.0, 1.0, 2.5), Vector3(1.6, 2.4, 1.4), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"church_storeroom_clue",
		"interaction_verb": &"examine",
	})
	builder.add_target(self, "PriestDialogue", Vector3(-4.0, 1.0, -1.0), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"priest_dialogue",
	})
