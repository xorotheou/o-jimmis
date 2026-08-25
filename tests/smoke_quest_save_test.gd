extends Node
## Headless runtime smoke test for quest state round-tripping through save/load.

const SAVE_PATH := "user://smoke_quest_save_test.json"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	_reset_runtime_state()

	var quest := AdventureQuestDefinition.new()
	quest.quest_id = &"smoke_quest_save"
	quest.title = "Smoke Quest Save"
	quest.objective_ids = [&"smoke_quest_save_a", &"smoke_quest_save_b"]
	quest.completion_actions = [
		{"type": "set_flag", "id": "smoke_quest_save_completed", "value": true}
	]

	Quests.register_definition(quest)

	_assert(Quests.start(&"smoke_quest_save"), "Quest did not start.")
	_assert(Quests.complete_objective(&"smoke_quest_save", &"smoke_quest_save_a"), "First objective did not complete.")
	_assert(not Quests.get_state(&"smoke_quest_save").completed, "Quest should still be in progress before saving.")

	Clock.set_time(777)
	GameState.set_value(&"smoke_round_trip", "before-save")
	Story.set_variable(&"smoke_round_trip_story", "before-save")
	_assert(Save.save_game(SAVE_PATH) == OK, "First save failed.")

	_reset_runtime_state()
	_assert(Save.load_game(SAVE_PATH) == OK, "First load failed.")
	_assert(Quests.get_state(&"smoke_quest_save").objectives.has(&"smoke_quest_save_a"), "Quest objective A did not restore.")
	_assert(not Quests.get_state(&"smoke_quest_save").completed, "Quest should still be incomplete after restore.")
	_assert(String(GameState.get_value(&"smoke_round_trip", "")) == "before-save", "GameState marker did not restore after reset.")
	_assert(String(Story.get_variable(&"smoke_round_trip_story", "")) == "before-save", "Story scratch variable did not restore after reset.")
	_assert(Clock.minutes_since_midnight == 777, "Clock did not restore.")

	_assert(Quests.complete_objective(&"smoke_quest_save", &"smoke_quest_save_b"), "Second objective did not complete.")
	_assert(Story.has_flag(&"smoke_quest_save_completed"), "Quest completion flag did not set.")
	_assert(Quests.get_state(&"smoke_quest_save").completed, "Quest should be completed after the second objective.")

	Clock.set_time(912)
	GameState.set_value(&"smoke_round_trip", "after-complete")
	Story.set_variable(&"smoke_round_trip_story", "after-complete")
	_assert(Save.save_game(SAVE_PATH) == OK, "Second save failed.")

	_reset_runtime_state()
	_assert(Save.load_game(SAVE_PATH) == OK, "Second load failed.")
	_assert(Quests.get_state(&"smoke_quest_save").completed, "Completed quest did not restore.")
	_assert(Story.has_flag(&"smoke_quest_save_completed"), "Quest completion flag did not restore.")
	_assert(Clock.minutes_since_midnight == 912, "Clock did not restore after completion save.")
	_assert(String(GameState.get_value(&"smoke_round_trip", "")) == "after-complete", "GameState marker did not restore after completion save.")
	_assert(String(Story.get_variable(&"smoke_round_trip_story", "")) == "after-complete", "Story variable did not restore after completion save.")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit(0 if _failures.is_empty() else 1)

func _reset_runtime_state() -> void:
	GameState.reset()
	Story.restore({})
	Inventory.restore({})
	Puzzles.restore({})
	Quests.restore({})
	Npcs.restore({})
	Clock.set_time(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
