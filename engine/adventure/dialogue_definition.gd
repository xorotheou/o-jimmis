class_name AdventureDialogueDefinition
extends Resource
## Conversation graph authored as dictionaries with id, text, choices, conditions, and consequences.

@export var dialogue_id: StringName
@export var start_node_id: StringName
@export var nodes: Array[Dictionary] = []

func get_node(node_id: StringName) -> Dictionary:
	for node in nodes:
		if StringName(node.get("id", "")) == node_id:
			return node.duplicate(true)
	return {}
