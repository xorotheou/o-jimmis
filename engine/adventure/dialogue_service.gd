extends Node
## Deterministic dialogue graph runner. Presentation renders returned text and choices.

const AdventureActionExecutor = preload("res://engine/adventure/action_executor.gd")

signal conversation_started(dialogue_id: StringName, node_id: StringName)
signal dialogue_advanced(dialogue_id: StringName, node_id: StringName)
signal conversation_ended(dialogue_id: StringName)
var _definitions: Dictionary = {}
var _active_dialogue: Variant = null
var _active_node_id: StringName

func register_definition(definition) -> void:
	assert(not definition.dialogue_id.is_empty() and not definition.start_node_id.is_empty(), "Dialogue needs ids")
	assert(not definition.get_node(definition.start_node_id).is_empty(), "Dialogue start node is missing")
	_definitions[definition.dialogue_id] = definition

func start(dialogue_id: StringName) -> Dictionary:
	_active_dialogue = _definitions.get(dialogue_id)
	if _active_dialogue == null:
		return {}
	_active_node_id = _active_dialogue.start_node_id
	conversation_started.emit(dialogue_id, _active_node_id)
	return current_node()

func current_node() -> Dictionary:
	if _active_dialogue == null:
		return {}
	var node: Dictionary = _active_dialogue.get_node(_active_node_id)
	if node.is_empty() or not _conditions_met(node.get("conditions", [])):
		return {}
	node["choices"] = available_choices(node)
	return node

func available_choices(node: Dictionary) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for choice: Dictionary in node.get("choices", []):
		if _conditions_met(choice.get("conditions", [])):
			available.append(choice.duplicate(true))
	return available

func choose(choice_id: StringName) -> Dictionary:
	var node: Dictionary = current_node()
	for choice: Dictionary in node.get("choices", []):
		if StringName(choice.get("id", "")) != choice_id or not _conditions_met(choice.get("conditions", [])):
			continue
		if not AdventureActionExecutor.execute(choice.get("consequences", [])):
			return {}
		_active_node_id = StringName(choice.get("next_node_id", ""))
		if _active_node_id.is_empty():
			conversation_ended.emit(_active_dialogue.dialogue_id)
			_active_dialogue = null
			return {}
		dialogue_advanced.emit(_active_dialogue.dialogue_id, _active_node_id)
		return current_node()
	return {}

func _conditions_met(conditions: Array[Dictionary]) -> bool:
	return Interaction._conditions_met(conditions)
