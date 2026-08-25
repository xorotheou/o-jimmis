extends Node3D

@onready var builder := preload("res://content/jimmis/locations/location_builder.gd").new()
const WorldTarget := preload("res://engine/world/world_target.gd")

func _ready() -> void:
	builder.add_directional_light(self, "StreetLight", Vector3(0.0, 10.0, 0.0))
	builder.add_floor(self, "StreetFloor", Vector3(24.0, 0.2, 16.0))
	builder.add_navigation_region(self, "StreetNavigation", Vector3(24.0, 3.0, 16.0))

	builder.add_mesh_cube(self, "Workshop", Vector3(5.0, 1.5, -4.0), Vector3(5.0, 3.0, 4.0), Color(0.68, 0.58, 0.48))
	builder.add_mesh_cube(self, "UtilityShed", Vector3(-5.0, 1.0, 3.0), Vector3(3.0, 2.0, 2.0), Color(0.5, 0.46, 0.4))
	builder.add_mesh_cube(self, "CablePile", Vector3(2.0, 0.25, 2.5), Vector3(1.4, 0.5, 1.4), Color(0.36, 0.28, 0.2))

	builder.add_spawn(self, "StreetEntry", Vector3(0.0, 0.5, 6.0), &"street_entry")

	var camera_a := builder.add_camera(self, "CameraStreetWide", Transform3D(Basis(Vector3.UP, deg_to_rad(20.0)), Vector3(0.0, 8.0, 11.0)), true)
	var camera_b := builder.add_camera(self, "CameraStreetWorkshop", Transform3D(Basis(Vector3.UP, deg_to_rad(-20.0)), Vector3(4.0, 6.5, 5.0)))
	var camera_c := builder.add_camera(self, "CameraStreetShed", Transform3D(Basis(Vector3.UP, deg_to_rad(35.0)), Vector3(-5.0, 5.5, 7.0)))
	builder.add_camera_zone(self, "StreetZoneWide", Vector3(0.0, 1.0, 1.0), camera_a.get_path(), Vector3(14.0, 3.0, 10.0))
	builder.add_camera_zone(self, "StreetZoneWorkshop", Vector3(4.0, 1.0, -2.0), camera_b.get_path(), Vector3(8.0, 3.0, 6.0))
	builder.add_camera_zone(self, "StreetZoneShed", Vector3(-4.0, 1.0, 2.0), camera_c.get_path(), Vector3(8.0, 3.0, 6.0))

	builder.add_target(self, "StreetReturn", Vector3(0.0, 1.0, 7.5), Vector3(3.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"village_square",
		"spawn_id": &"square_north",
	})
	builder.add_target(self, "TheoDialogue", Vector3(4.0, 1.0, -2.0), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"theo_dialogue",
	})
	builder.add_target(self, "WirePickup", Vector3(1.5, 0.8, 3.0), Vector3(1.4, 1.4, 1.4), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"street_wire",
		"interaction_verb": &"take",
	})
	builder.add_target(self, "FusePickup", Vector3(-3.5, 0.8, 2.5), Vector3(1.4, 1.4, 1.4), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"street_fuse",
		"interaction_verb": &"take",
	})
