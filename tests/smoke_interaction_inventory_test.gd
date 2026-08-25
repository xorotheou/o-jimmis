extends Node
## Headless runtime smoke test for interaction-driven item acquisition and combination.

var _failures: Array[String] = []
var _interaction_seen := ""

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var found_key := AdventureItemDefinition.new()
	found_key.item_id = &"smoke_chain_key"
	found_key.display_name = "Chain Key"
	found_key.stackable = false

	var door_handle := AdventureItemDefinition.new()
	door_handle.item_id = &"smoke_chain_handle"
	door_handle.display_name = "Door Handle"
	door_handle.stackable = false
	door_handle.combination_results = {&"smoke_chain_key": &"smoke_chain_opened"}

	var opened := AdventureItemDefinition.new()
	opened.item_id = &"smoke_chain_opened"
	opened.display_name = "Opened Door"
	opened.stackable = false

	Inventory.register_definition(found_key)
	Inventory.register_definition(door_handle)
	Inventory.register_definition(opened)

	var interaction := AdventureInteractionDefinition.new()
	interaction.interaction_id = &"smoke_chest"
	interaction.verb = &"open"
	interaction.response_text = "You find a key."
	interaction.consequences = [
		{"type": "add_item", "id": "smoke_chain_key", "quantity": 1}
	]
	Interaction.interaction_resolved.connect(_on_interaction_resolved)
	Interaction.register_definition(interaction)

	_assert(Inventory.add_item(&"smoke_chain_handle"), "Could not add the handle.")
	_assert(Interaction.resolve(&"smoke_chest", &"open") == "You find a key.", "Interaction did not grant the expected item.")
	_assert(_interaction_seen == "You find a key.", "Interaction signal did not emit the expected response.")
	_assert(Inventory.has_item(&"smoke_chain_key"), "Interaction did not add the key.")

	var result_id := Inventory.combine(&"smoke_chain_handle", &"smoke_chain_key")
	_assert(result_id == &"smoke_chain_opened", "Interaction + inventory chain did not combine correctly.")
	_assert(Inventory.has_item(&"smoke_chain_opened"), "Combined result item was not added.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

func _on_interaction_resolved(_interaction_id: StringName, _verb: StringName, response_text: String) -> void:
	_interaction_seen = response_text
