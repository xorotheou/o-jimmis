extends Node
## Resolves authored interactions without placing game logic in scene scripts.

signal interaction_resolved(interaction_id: StringName, verb: StringName, response_text: String)
var _definitions: Dictionary = {}

func register_definition(definition: AdventureInteractionDefinition) -> void:
	assert(not definition.interaction_id.is_empty() and not definition.verb.is_empty(), "Interaction needs an id and verb")
	_definitions["%s:%s" % [definition.interaction_id, definition.verb]] = definition

func resolve(interaction_id: StringName, verb: StringName) -> String:
	var definition: AdventureInteractionDefinition = _definitions.get("%s:%s" % [interaction_id, verb])
	if definition == null or not _conditions_met(definition.conditions):
		return ""
	if not AdventureActionExecutor.execute(definition.consequences):
		return ""
	interaction_resolved.emit(interaction_id, verb, definition.response_text)
	return definition.response_text

func _conditions_met(conditions: Array[Dictionary]) -> bool:
	for condition in conditions:
		match StringName(condition.get("type", "")):
			&"flag":
				if Story.has_flag(StringName(condition.get("id", ""))) != bool(condition.get("value", true)): return false
			&"has_item":
				if Inventory.has_item(StringName(condition.get("id", ""))) != bool(condition.get("value", true)): return false
			_:
				Log.error("adventure", "Unknown interaction condition", condition)
				return false
	return true
