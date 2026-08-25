extends Node
## Tracks inactive, partial, completed, and resettable puzzle state.

const AdventureActionExecutor = preload("res://engine/adventure/action_executor.gd")

signal puzzle_progressed(puzzle_id: StringName, progress: Dictionary)
signal puzzle_completed(puzzle_id: StringName)
var _definitions: Dictionary = {}
var _progress: Dictionary = {}

func register_definition(definition) -> void:
	assert(not definition.puzzle_id.is_empty(), "Puzzle needs an id")
	_definitions[definition.puzzle_id] = definition

func get_registered_puzzle_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for puzzle_id in _definitions.keys():
		ids.append(puzzle_id)
	return ids

func update_progress(puzzle_id: StringName, update: Dictionary) -> bool:
	var definition: Variant = _definitions.get(puzzle_id)
	if definition == null or is_completed(puzzle_id) or not Interaction._conditions_met(definition.prerequisites):
		return false
	var progress: Dictionary = _progress.get(puzzle_id, {}).duplicate(true)
	progress.merge(update, true)
	_progress[puzzle_id] = progress
	puzzle_progressed.emit(puzzle_id, progress)
	return true

func complete(puzzle_id: StringName) -> bool:
	var definition: Variant = _definitions.get(puzzle_id)
	if definition == null or is_completed(puzzle_id) or not Interaction._conditions_met(definition.prerequisites):
		return false
	if not AdventureActionExecutor.execute(definition.completion_actions):
		return false
	_progress[puzzle_id] = {"completed": true}
	puzzle_completed.emit(puzzle_id)
	return true

func is_completed(puzzle_id: StringName) -> bool:
	return bool(_progress.get(puzzle_id, {}).get("completed", false))

func reset(puzzle_id: StringName) -> bool:
	var definition: Variant = _definitions.get(puzzle_id)
	if definition == null or not definition.resettable:
		return false
	_progress.erase(puzzle_id)
	return true

func snapshot() -> Dictionary:
	return _progress.duplicate(true)

func restore(snapshot_data: Dictionary) -> void:
	_progress = snapshot_data.duplicate(true)
