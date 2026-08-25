extends Node
## Headless runtime smoke test for deterministic save/load restoration.

const SAVE_PATH := "user://smoke_save_test.json"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var state_key := &"smoke/value"
	var flag_id := &"smoke_flag"
	var variable_id := &"smoke_var"

	GameState.set_value(state_key, 17)
	Story.set_flag(flag_id, true)
	Story.set_variable(variable_id, "before-save")
	Clock.set_time(915)

	_assert(Save.save_game(SAVE_PATH) == OK, "Save failed.")

	GameState.set_value(state_key, 91)
	Story.set_flag(flag_id, false)
	Story.set_variable(variable_id, "after-save")
	Clock.set_time(120)

	_assert(Save.load_game(SAVE_PATH) == OK, "Load failed.")
	_assert(int(GameState.get_value(state_key, -1)) == 17, "GameState did not restore.")
	_assert(Story.has_flag(flag_id), "Story flag did not restore.")
	_assert(String(Story.get_variable(variable_id, "")) == "before-save", "Story variable did not restore.")
	_assert(Clock.minutes_since_midnight == 915, "Clock did not restore.")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
