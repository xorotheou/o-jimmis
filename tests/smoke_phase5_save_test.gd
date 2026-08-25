extends Node

const Support = preload("res://tests/phase5_test_support.gd")

const SAVE_PATH := "user://smoke_phase5_save_test.json"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var runtime := Support.setup_runtime("Phase5SaveHost")
	var host: Node = runtime["host"]

	_assert(World.load_location(&"village_square", &"square_west"), "Village square did not load.")
	_assert(Dialogue.start(&"cafe_owner_dialogue").size() > 0, "Cafe owner dialogue did not start.")
	_assert(Dialogue.choose(&"ask_church").size() > 0, "Cafe owner quest start did not advance.")
	_assert(World.load_location(&"main_street", &"street_entry"), "Main street did not load.")
	_assert(Interaction.resolve(&"street_wire", &"take") != "", "Wire pickup failed.")
	_assert(Interaction.resolve(&"street_fuse", &"take") != "", "Fuse pickup failed.")
	_assert(Inventory.combine(&"old_wire", &"electrical_fuse") == &"repaired_fuse", "Repair parts did not combine.")
	_assert(Dialogue.start(&"theo_dialogue").size() > 0, "Theo dialogue did not start before save.")
	_assert(Dialogue.choose(&"borrow_pliers").size() > 0, "Theo pliers branch did not advance before save.")
	Quests.complete_objective(&"vertical_slice_church_problem", &"find_repair_materials")
	_assert(Save.save_game(SAVE_PATH) == OK, "Midquest save failed.")

	Support.reset_runtime()
	_assert(Save.load_game(SAVE_PATH) == OK, "Midquest load failed.")
	_assert(World.current_location_id == &"main_street", "Midquest location did not restore.")
	_assert(World.current_spawn_id == &"street_entry", "Midquest spawn did not restore.")
	_assert(Inventory.has_item(&"repaired_fuse"), "Repaired fuse did not restore.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").started, "Quest did not restore as started.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"find_repair_materials"), "Repair materials objective did not restore.")

	_assert(Interaction.resolve(&"church_power_box", &"use") != "", "Church power box did not complete.")
	_assert(Story.has_flag(&"electrical_problem_fixed"), "Electrical repair flag did not set.")
	Quests.complete_objective(&"vertical_slice_church_problem", &"repair_nicola_problem")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"repair_nicola_problem"), "Repair objective did not complete.")
	_assert(Dialogue.start(&"nicola_dialogue").size() > 0, "Nicola dialogue did not start after repair.")
	_assert(Dialogue.choose(&"give_fuse").size() > 0, "Nicola key handoff did not advance.")
	_assert(Inventory.has_item(&"church_key"), "Church key did not arrive.")
	_assert(Story.has_flag(&"church_access_unlocked"), "Church access did not unlock.")

	_assert(World.load_location(&"church_exterior", &"church_entry"), "Church exterior did not load.")
	_assert(World.load_location(&"church_interior", &"church_interior_entry"), "Church interior did not load.")
	Quests.complete_objective(&"vertical_slice_church_problem", &"enter_church")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"enter_church"), "Church entry objective did not complete.")
	_assert(Interaction.resolve(&"church_storeroom_clue", &"examine") != "", "Storeroom clue interaction failed.")
	for objective_id in Support.CONTENT.quest_objectives():
		Quests.complete_objective(&"vertical_slice_church_problem", objective_id)
	Quests.complete_objective(&"vertical_slice_church_problem", &"discover_clue")
	_assert(Quests.get_state(&"vertical_slice_church_problem").completed, "Quest did not complete before save.")
	_assert(Story.has_flag(&"storeroom_clue_found"), "Storeroom clue flag did not set.")

	_assert(Save.save_game(SAVE_PATH) == OK, "Postquest save failed.")
	Support.reset_runtime()
	_assert(Save.load_game(SAVE_PATH) == OK, "Postquest load failed.")
	_assert(World.current_location_id == &"church_interior", "Postquest location did not restore.")
	_assert(World.current_spawn_id == &"church_interior_entry", "Postquest spawn did not restore.")
	_assert(Story.has_flag(&"vertical_slice_complete"), "Vertical slice completion flag did not restore.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").completed, "Quest completion did not restore.")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	Support.cleanup_runtime(host)
	await get_tree().process_frame
	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
