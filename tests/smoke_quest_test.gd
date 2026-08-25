extends Node
## Headless runtime smoke test for deterministic quest progression.

var _failures: Array[String] = []
var _quest_started_seen := false
var _objective_events: Array[StringName] = []
var _quest_completed_seen := false

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var quest := AdventureQuestDefinition.new()
	quest.quest_id = &"smoke_quest"
	quest.title = "Smoke Quest"
	quest.objective_ids = [&"smoke_objective_a", &"smoke_objective_b"]
	quest.completion_actions = [
		{"type": "set_flag", "id": "smoke_quest_completed", "value": true}
	]

	Quests.quest_started.connect(_on_quest_started)
	Quests.objective_completed.connect(_on_objective_completed)
	Quests.quest_completed.connect(_on_quest_completed)

	Quests.register_definition(quest)

	_assert(Quests.start(&"smoke_quest"), "Quest did not start.")
	_assert(_quest_started_seen, "Quest started signal did not fire.")
	_assert(Quests.get_state(&"smoke_quest").started, "Started quest state is missing.")
	_assert(not Quests.get_state(&"smoke_quest").completed, "Quest should not be completed after start.")
	_assert(_objective_events.is_empty(), "No objectives should be complete immediately after start.")
	_assert(not Story.has_flag(&"smoke_quest_completed"), "Quest reward flag should not be set before completion.")

	_assert(Quests.complete_objective(&"smoke_quest", &"smoke_objective_a"), "First objective did not complete.")
	_assert(_objective_events.has(&"smoke_objective_a"), "First objective signal did not fire.")
	_assert(not _quest_completed_seen, "Quest should not complete after the first objective.")
	_assert(not Story.has_flag(&"smoke_quest_completed"), "Quest reward flag should not be set after the first objective.")

	_assert(Quests.complete_objective(&"smoke_quest", &"smoke_objective_b"), "Second objective did not complete.")
	_assert(_objective_events.has(&"smoke_objective_b"), "Second objective signal did not fire.")
	_assert(_quest_completed_seen, "Quest completed signal did not fire.")
	_assert(Quests.get_state(&"smoke_quest").completed, "Quest state should be completed after all objectives.")
	_assert(Story.has_flag(&"smoke_quest_completed"), "Quest reward flag was not set on completion.")

	_assert(not Quests.complete_objective(&"smoke_quest", &"smoke_objective_b"), "Completed quest should not accept duplicate objective completion.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

func _on_quest_started(quest_id: StringName) -> void:
	if quest_id == &"smoke_quest":
		_quest_started_seen = true

func _on_objective_completed(quest_id: StringName, objective_id: StringName) -> void:
	if quest_id == &"smoke_quest":
		_objective_events.append(objective_id)

func _on_quest_completed(quest_id: StringName) -> void:
	if quest_id == &"smoke_quest":
		_quest_completed_seen = true
