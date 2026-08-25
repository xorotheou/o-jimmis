extends Node3D

@onready var builder := preload("res://content/jimmis/locations/location_builder.gd").new()
const WorldTarget := preload("res://engine/world/world_target.gd")

func _ready() -> void:
	builder.add_directional_light(self, "SunLight", Vector3(0.0, 10.0, 0.0))
	builder.add_floor(self, "SquareFloor", Vector3(30.0, 0.2, 30.0))
	builder.add_navigation_region(self, "SquareNavigation", Vector3(30.0, 3.0, 30.0))

	builder.add_mesh_cube(self, "CafeFacade", Vector3(-10.0, 1.2, -8.0), Vector3(5.0, 2.4, 4.0), Color(0.82, 0.74, 0.66))
	builder.add_mesh_cube(self, "ChurchFacade", Vector3(10.0, 1.8, -8.0), Vector3(6.0, 3.6, 4.0), Color(0.86, 0.84, 0.78))
	builder.add_mesh_cube(self, "MainStreetArch", Vector3(0.0, 1.0, 11.0), Vector3(4.0, 2.0, 2.0), Color(0.74, 0.68, 0.62))
	builder.add_mesh_cube(self, "FountainBase", Vector3(0.0, 0.25, 0.0), Vector3(2.4, 0.5, 2.4), Color(0.55, 0.65, 0.74))

	builder.add_spawn(self, "SpawnWest", Vector3(-9.0, 0.5, 2.5), &"square_west")
	builder.add_spawn(self, "SpawnEast", Vector3(9.0, 0.5, 2.5), &"square_east")
	builder.add_spawn(self, "SpawnNorth", Vector3(0.0, 0.5, -6.0), &"square_north")

	var camera_a := builder.add_camera(self, "CameraSquareWide", Transform3D(Basis.IDENTITY, Vector3(0.0, 9.0, 14.0)), true)
	var camera_b := builder.add_camera(self, "CameraSquareCafe", Transform3D(Basis(Vector3.UP, deg_to_rad(25.0)), Vector3(-10.0, 8.0, 5.0)))
	var camera_c := builder.add_camera(self, "CameraSquareChurch", Transform3D(Basis(Vector3.UP, deg_to_rad(-25.0)), Vector3(10.0, 9.0, 5.0)))

	builder.add_camera_zone(self, "ZoneCafe", Vector3(-8.0, 1.0, -1.0), camera_b.get_path(), Vector3(8.0, 3.0, 8.0))
	builder.add_camera_zone(self, "ZoneChurch", Vector3(8.0, 1.0, -1.0), camera_c.get_path(), Vector3(8.0, 3.0, 8.0))
	builder.add_camera_zone(self, "ZoneCenter", Vector3(0.0, 1.0, 0.0), camera_a.get_path(), Vector3(14.0, 3.0, 14.0))

	builder.add_target(self, "CafeExit", Vector3(-12.0, 0.8, -6.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"cafe",
		"spawn_id": &"cafe_entry",
	})
	builder.add_target(self, "ChurchExit", Vector3(12.0, 1.0, -6.5), Vector3(2.0, 3.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"church_exterior",
		"spawn_id": &"church_entry",
	})
	builder.add_target(self, "StreetExit", Vector3(0.0, 1.0, 13.0), Vector3(3.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"main_street",
		"spawn_id": &"street_entry",
	})
	builder.add_target(self, "CafeOwnerDialogue", Vector3(-8.5, 1.0, -4.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"cafe_owner_dialogue",
	})
	builder.add_target(self, "PriestDialogue", Vector3(9.0, 1.0, -4.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"priest_dialogue",
	})
	builder.add_target(self, "VillagerDialogue", Vector3(1.5, 1.0, 4.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"villager_dialogue",
	})
	builder.add_target(self, "FountainLook", Vector3(0.0, 0.8, 0.0), Vector3(3.0, 2.0, 3.0), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"square_fountain",
		"interaction_verb": &"look",
	})
	builder.add_target(self, "NoticeboardLook", Vector3(0.0, 1.0, 8.0), Vector3(2.0, 2.0, 1.5), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"square_noticeboard",
		"interaction_verb": &"look",
	})
