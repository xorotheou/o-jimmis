class_name AdventureItemDefinition
extends Resource
## Content-authored inventory item. IDs are stable save-data keys.

@export var item_id: StringName
@export var display_name := ""
@export_multiline var inspection_text := ""
@export var stackable := false
@export var combination_results: Dictionary = {}

func is_valid_definition() -> bool:
	return not item_id.is_empty() and not display_name.is_empty()

func result_for(other_item_id: StringName) -> StringName:
	return StringName(combination_results.get(other_item_id, &""))
