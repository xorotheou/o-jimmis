extends Node

const Support = preload("res://tests/phase5_test_support.gd")

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var runtime := Support.setup_runtime("Phase5FlowHost")
	var host: Node = runtime["host"]

	_assert(World.load_location(&"village_square", &"square_west"), "Village square did not load.")
	_assert(Dialogue.start(&"cafe_owner_dialogue").size() > 0, "Costa dialogue did not start.")
	_assert(Dialogue.choose(&"ask_church").size() > 0, "Costa church branch did not advance.")
	_assert(World.load_location(&"main_street", &"street_entry"), "Main street did not load.")
	_assert(Interaction.resolve(&"street_wire", &"take") != "", "Wire pickup failed.")
	_assert(Interaction.resolve(&"street_fuse", &"take") != "", "Fuse pickup failed.")
	_assert(Inventory.combine(&"old_wire", &"electrical_fuse") == &"repaired_fuse", "Repair parts did not combine.")
	_assert(Dialogue.start(&"theo_dialogue").size() > 0, "Theo dialogue did not start.")
	_assert(Dialogue.choose(&"borrow_pliers").size() > 0, "Theo pliers branch did not advance.")
	Quests.complete_objective(&"vertical_slice_church_problem", &"find_repair_materials")
	_assert(World.load_location(&"church_exterior", &"church_entry"), "Church exterior did not load.")
	_assert(Interaction.resolve(&"church_power_box", &"use") != "", "Church power box did not complete.")
	Quests.complete_objective(&"vertical_slice_church_problem", &"repair_nicola_problem")
	_assert(Dialogue.start(&"nicola_dialogue").size() > 0, "Nicola dialogue did not start.")
	_assert(Dialogue.choose(&"give_fuse").size() > 0, "Nicola key handoff did not advance.")
	_assert(Inventory.has_item(&"church_key"), "Church key did not arrive.")
	_assert(Npcs.get_relationship(&"nicola") > 0, "Nicola relationship did not improve.")
	_assert(World.load_location(&"church_interior", &"church_interior_entry"), "Church interior did not load.")
	Quests.complete_objective(&"vertical_slice_church_problem", &"enter_church")
	_assert(Interaction.resolve(&"church_storeroom_clue", &"examine") != "", "Storeroom clue interaction failed.")
	for objective_id in Support.CONTENT.quest_objectives():
		Quests.complete_objective(&"vertical_slice_church_problem", objective_id)
	Quests.complete_objective(&"vertical_slice_church_problem", &"discover_clue")

	_assert(Quests.get_state(&"vertical_slice_church_problem").completed, "Vertical slice quest did not complete.")
	_assert(Story.has_flag(&"vertical_slice_complete"), "Vertical slice completion flag did not set.")
	_assert(Story.has_flag(&"church_access_unlocked"), "Church access flag did not set.")
	_assert(Story.has_flag(&"storeroom_clue_found"), "Storeroom clue flag did not set.")
	_assert(host.find_children("*", "CharacterBody3D", true, false).size() == 1, "Player duplicated during location transitions.")

	Support.cleanup_runtime(host)
	await get_tree().process_frame
	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
