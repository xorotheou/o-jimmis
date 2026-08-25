extends Node

const Support = preload("res://tests/phase5_test_support.gd")

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	Support.register_content()

	var node := Dialogue.start(&"cafe_owner_dialogue")
	_assert(not node.is_empty(), "Cafe owner dialogue did not start.")
	_assert(String(node.get("text", "")).contains("Costa"), "Cafe owner dialogue start text is wrong.")
	_assert(Dialogue.choose(&"ask_nicola").get("id", "") == &"nicola_intro", "Cafe owner branch did not advance.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"ask_cafe_owner"), "Cafe owner objective did not complete.")
	_assert(Npcs.get_relationship(&"cafe_owner") == 2, "Cafe owner relationship did not change.")
	_assert(Npcs.get_memories(&"cafe_owner").size() > 0, "Cafe owner memory was not recorded.")

	node = Dialogue.start(&"theo_dialogue")
	_assert(not node.is_empty(), "Theo dialogue did not start.")
	_assert(Dialogue.choose(&"borrow_pliers").get("id", "") == &"pliers", "Theo branch did not advance.")
	_assert(Inventory.has_item(&"pliers"), "Theo did not give the pliers.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"visit_theo"), "Theo objective did not complete.")
	_assert(Npcs.get_memories(&"theo").size() > 0, "Theo memory was not recorded.")
	_assert(Npcs.fallback_line(&"theo") != "", "Theo fallback line is missing.")

	node = Dialogue.start(&"nicola_dialogue")
	_assert(not node.is_empty(), "Nicola dialogue did not start.")
	_assert(Dialogue.choose(&"ask_problem").get("id", "") == &"problem", "Nicola branch did not advance.")
	_assert(Story.has_flag(&"nicola_problem_discovered"), "Nicola problem flag did not set.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"speak_with_nicola"), "Nicola objective did not complete.")

	node = Dialogue.start(&"priest_dialogue")
	_assert(not node.is_empty(), "Priest dialogue did not start.")
	_assert(Dialogue.choose(&"ask_rumour").get("id", "") == &"rumour", "Priest branch did not advance.")
	_assert(Quests.get_state(&"vertical_slice_church_problem").objectives.has(&"investigate_church"), "Investigation objective did not complete.")
	_assert(Story.has_flag(&"heard_priest_rumour"), "Priest rumour flag did not set.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
