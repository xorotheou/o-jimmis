extends Node3D

@onready var builder := preload("res://content/jimmis/locations/location_builder.gd").new()
const WorldTarget := preload("res://engine/world/world_target.gd")

func _ready() -> void:
	builder.add_directional_light(self, "CafeLight", Vector3(0.0, 8.0, 0.0))
	builder.add_floor(self, "CafeFloor", Vector3(18.0, 0.2, 14.0))
	builder.add_navigation_region(self, "CafeNavigation", Vector3(18.0, 3.0, 14.0))

	builder.add_mesh_cube(self, "CafeBar", Vector3(-5.0, 1.0, -4.0), Vector3(4.0, 2.0, 1.4), Color(0.62, 0.44, 0.34))
	builder.add_mesh_cube(self, "CafeTable", Vector3(2.5, 0.75, 1.5), Vector3(1.4, 1.5, 1.4), Color(0.72, 0.56, 0.38))
	builder.add_mesh_cube(self, "CafeWindow", Vector3(0.0, 1.8, -6.4), Vector3(10.0, 2.6, 0.5), Color(0.86, 0.82, 0.72))

	builder.add_spawn(self, "CafeEntrySpawn", Vector3(0.0, 0.5, 5.0), &"cafe_entry")

	var camera_a := builder.add_camera(self, "CameraCafeWide", Transform3D(Basis(Vector3.UP, deg_to_rad(20.0)), Vector3(0.0, 6.5, 10.0)), true)
	var camera_b := builder.add_camera(self, "CameraCafeCounter", Transform3D(Basis(Vector3.UP, deg_to_rad(-35.0)), Vector3(-4.0, 5.5, 3.0)))
	builder.add_camera_zone(self, "CafeZoneWide", Vector3(0.0, 1.0, 1.0), camera_a.get_path(), Vector3(12.0, 3.0, 10.0))
	builder.add_camera_zone(self, "CafeZoneCounter", Vector3(-4.0, 1.0, -2.5), camera_b.get_path(), Vector3(8.0, 3.0, 6.0))

	builder.add_target(self, "CafeReturn", Vector3(0.0, 1.0, 6.5), Vector3(3.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.EXIT,
		"location_id": &"village_square",
		"spawn_id": &"square_west",
	})
	builder.add_target(self, "CafeOwnerDialogue", Vector3(-4.5, 1.0, -1.5), Vector3(2.0, 2.0, 2.0), {
		"target_kind": WorldTarget.TargetKind.DIALOGUE,
		"dialogue_id": &"cafe_owner_dialogue",
	})
	builder.add_target(self, "ReceiptPickup", Vector3(3.0, 1.0, -2.5), Vector3(1.5, 1.5, 1.5), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"cafe_receipt",
		"interaction_verb": &"take",
	})
	builder.add_target(self, "EspressoMachine", Vector3(4.8, 1.0, -4.0), Vector3(1.5, 2.0, 1.5), {
		"target_kind": WorldTarget.TargetKind.INTERACTION,
		"target_id": &"cafe_machine",
		"interaction_verb": &"use",
	})
