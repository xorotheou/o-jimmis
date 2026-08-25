extends Node
## Deterministic quest and objective state authority.

const AdventureActionExecutor = preload("res://engine/adventure/action_executor.gd")

signal quest_started(quest_id: StringName)
signal objective_completed(quest_id: StringName, objective_id: StringName)
signal quest_completed(quest_id: StringName)
var _definitions: Dictionary = {}
var _states: Dictionary = {}

func register_definition(definition) -> void:
	assert(not definition.quest_id.is_empty(), "Quest needs an id")
	_definitions[definition.quest_id] = definition

func start(quest_id: StringName) -> bool:
	if not _definitions.has(quest_id) or _states.has(quest_id): return false
	_states[quest_id] = {"started": true, "objectives": {}, "completed": false}
	quest_started.emit(quest_id)
	return true

func complete_objective(quest_id: StringName, objective_id: StringName) -> bool:
	var definition: Variant = _definitions.get(quest_id)
	var state: Dictionary = _states.get(quest_id, {})
	if definition == null or state.is_empty() or not definition.objective_ids.has(objective_id) or bool(state.completed): return false
	state.objectives[objective_id] = true
	_states[quest_id] = state
	objective_completed.emit(quest_id, objective_id)
	if _all_objectives_complete(definition, state):
		return _complete(quest_id, definition, state)
	return true

func _all_objectives_complete(definition, state: Dictionary) -> bool:
	for objective_id in definition.objective_ids:
		if not bool(state.objectives.get(objective_id, false)): return false
	return true

func _complete(quest_id: StringName, definition, state: Dictionary) -> bool:
	if not AdventureActionExecutor.execute(definition.completion_actions): return false
	state.completed = true
	_states[quest_id] = state
	quest_completed.emit(quest_id)
	return true

func get_state(quest_id: StringName) -> Dictionary:
	return _states.get(quest_id, {}).duplicate(true)

func snapshot() -> Dictionary:
	return _states.duplicate(true)

func restore(snapshot_data: Dictionary) -> void:
	_states = snapshot_data.duplicate(true)
