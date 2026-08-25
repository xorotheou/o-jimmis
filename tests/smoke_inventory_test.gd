extends Node
## Headless runtime smoke test for deterministic inventory combination.

var _failures: Array[String] = []
var _combined_first: StringName = &""
var _combined_second: StringName = &""
var _combined_result: StringName = &""

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var stick := AdventureItemDefinition.new()
	stick.item_id = &"smoke_stick"
	stick.display_name = "Stick"
	stick.stackable = false
	stick.combination_results = {&"smoke_stone": &"smoke_axe"}

	var stone := AdventureItemDefinition.new()
	stone.item_id = &"smoke_stone"
	stone.display_name = "Stone"
	stone.stackable = false

	var axe := AdventureItemDefinition.new()
	axe.item_id = &"smoke_axe"
	axe.display_name = "Axe"
	axe.stackable = false

	Inventory.items_combined.connect(_on_items_combined)

	Inventory.register_definition(stick)
	Inventory.register_definition(stone)
	Inventory.register_definition(axe)

	_assert(Inventory.add_item(&"smoke_stick"), "Could not add the first inventory item.")
	_assert(Inventory.add_item(&"smoke_stone"), "Could not add the second inventory item.")

	var result_id := Inventory.combine(&"smoke_stick", &"smoke_stone")

	_assert(result_id == &"smoke_axe", "Combine returned the wrong result id.")
	_assert(_combined_first == &"smoke_stick", "Combine signal used the wrong first id.")
	_assert(_combined_second == &"smoke_stone", "Combine signal used the wrong second id.")
	_assert(_combined_result == &"smoke_axe", "Combine signal used the wrong result id.")
	_assert(not Inventory.has_item(&"smoke_stick"), "First item should have been consumed.")
	_assert(not Inventory.has_item(&"smoke_stone"), "Second item should have been consumed.")
	_assert(Inventory.has_item(&"smoke_axe"), "Result item was not added.")
	_assert(Inventory.get_quantity(&"smoke_axe") == 1, "Result item quantity should be one.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

func _on_items_combined(first_item_id: StringName, second_item_id: StringName, result_item_id: StringName) -> void:
	_combined_first = first_item_id
	_combined_second = second_item_id
	_combined_result = result_item_id
