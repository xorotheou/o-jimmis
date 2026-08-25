extends Node

const Support = preload("res://tests/phase5_test_support.gd")

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	Support.register_content()
	_assert(World.get_registered_location_ids().size() == 5, "Expected five registered locations.")
	_assert(Support.has_id(World.get_registered_location_ids(), &"village_square"), "Village square location is missing.")
	_assert(Support.has_id(World.get_registered_location_ids(), &"cafe"), "Cafe location is missing.")
	_assert(Support.has_id(World.get_registered_location_ids(), &"church_exterior"), "Church exterior location is missing.")
	_assert(Support.has_id(World.get_registered_location_ids(), &"church_interior"), "Church interior location is missing.")
	_assert(Support.has_id(World.get_registered_location_ids(), &"main_street"), "Main street location is missing.")

	_assert(Inventory.get_registered_item_ids().size() >= 10, "Expected the vertical slice inventory set.")
	_assert(Support.has_id(Inventory.get_registered_item_ids(), &"old_wire"), "Old wire item is missing.")
	_assert(Support.has_id(Inventory.get_registered_item_ids(), &"electrical_fuse"), "Electrical fuse item is missing.")
	_assert(Support.has_id(Inventory.get_registered_item_ids(), &"repaired_fuse"), "Repaired fuse item is missing.")
	_assert(Support.has_id(Inventory.get_registered_item_ids(), &"retrieval_hook"), "Retrieval hook item is missing.")
	_assert(Support.has_id(Inventory.get_registered_item_ids(), &"church_key"), "Church key item is missing.")

	_assert(Npcs.get_registered_profile_ids().size() == 5, "Expected five NPC profiles.")
	_assert(Support.has_id(Npcs.get_registered_profile_ids(), &"cafe_owner"), "Cafe owner profile is missing.")
	_assert(Support.has_id(Npcs.get_registered_profile_ids(), &"nicola"), "Nicola profile is missing.")
	_assert(Support.has_id(Npcs.get_registered_profile_ids(), &"theo"), "Theo profile is missing.")
	_assert(Support.has_id(Npcs.get_registered_profile_ids(), &"priest"), "Priest profile is missing.")
	_assert(Support.has_id(Npcs.get_registered_profile_ids(), &"villager"), "Background villager profile is missing.")

	_assert(Dialogue.get_registered_dialogue_ids().size() == 5, "Expected five dialogue graphs.")
	_assert(Support.has_id(Dialogue.get_registered_dialogue_ids(), &"cafe_owner_dialogue"), "Cafe owner dialogue is missing.")
	_assert(Support.has_id(Dialogue.get_registered_dialogue_ids(), &"nicola_dialogue"), "Nicola dialogue is missing.")
	_assert(Support.has_id(Dialogue.get_registered_dialogue_ids(), &"theo_dialogue"), "Theo dialogue is missing.")
	_assert(Support.has_id(Dialogue.get_registered_dialogue_ids(), &"priest_dialogue"), "Priest dialogue is missing.")
	_assert(Support.has_id(Dialogue.get_registered_dialogue_ids(), &"villager_dialogue"), "Villager dialogue is missing.")

	_assert(Quests.get_registered_quest_ids().size() == 1, "Expected one phase 5 quest.")
	_assert(Support.has_id(Quests.get_registered_quest_ids(), &"vertical_slice_church_problem"), "Phase 5 quest is missing.")
	_assert(Puzzles.get_registered_puzzle_ids().size() == 1, "Expected one phase 5 puzzle.")
	_assert(Support.has_id(Puzzles.get_registered_puzzle_ids(), &"church_wiring_puzzle"), "Phase 5 puzzle is missing.")

	_assert(not World.load_location(&"missing_location"), "Unknown location should fail to load.")
	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
