extends Node
## Authoritative item ownership and per-item state. Definitions stay content-owned.

const ActionExecutor = preload("res://engine/adventure/action_executor.gd")

signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)
signal items_combined(first_item_id: StringName, second_item_id: StringName, result_item_id: StringName)

var _definitions: Dictionary = {}
var _quantities: Dictionary = {}
var _item_state: Dictionary = {}

func register_definition(definition) -> void:
	assert(definition.is_valid_definition(), "Inventory item definitions require an id and display name")
	_definitions[definition.item_id] = definition

func add_item(item_id: StringName, quantity := 1) -> bool:
	if not can_add_item(item_id, quantity):
		return false
	_quantities[item_id] = get_quantity(item_id) + quantity
	item_added.emit(item_id, quantity)
	return true

func can_add_item(item_id: StringName, quantity := 1) -> bool:
	if quantity <= 0 or not _definitions.has(item_id):
		return false
	if not _definitions[item_id].stackable and quantity != 1:
		return false
	if not _definitions[item_id].stackable and has_item(item_id):
		return false
	return true

func remove_item(item_id: StringName, quantity := 1) -> bool:
	if quantity <= 0 or get_quantity(item_id) < quantity:
		return false
	var remaining := get_quantity(item_id) - quantity
	if remaining == 0:
		_quantities.erase(item_id)
	else:
		_quantities[item_id] = remaining
	item_removed.emit(item_id, quantity)
	return true

func has_item(item_id: StringName) -> bool:
	return get_quantity(item_id) > 0

func get_quantity(item_id: StringName) -> int:
	return int(_quantities.get(item_id, 0))

func inspect_item(item_id: StringName) -> String:
	var definition: Variant = _definitions.get(item_id)
	return definition.inspection_text if definition != null and has_item(item_id) else ""

func set_item_state(item_id: StringName, state: Dictionary) -> void:
	assert(_definitions.has(item_id), "Item must be registered before setting state")
	_item_state[item_id] = state.duplicate(true)

func get_item_state(item_id: StringName) -> Dictionary:
	return _item_state.get(item_id, {}).duplicate(true)

func combine(first_item_id: StringName, second_item_id: StringName) -> StringName:
	if not has_item(first_item_id) or not has_item(second_item_id):
		return &""
	var first: Variant = _definitions[first_item_id]
	var result_id: StringName = StringName(first.result_for(second_item_id))
	if result_id.is_empty() or not _definitions.has(result_id):
		return &""
	if not can_add_item(result_id, 1):
		return &""
	if first_item_id == second_item_id and get_quantity(first_item_id) < 2:
		return &""
	var snapshot := snapshot()
	if not remove_item(first_item_id) or not remove_item(second_item_id) or not add_item(result_id):
		restore(snapshot)
		return &""
	items_combined.emit(first_item_id, second_item_id, result_id)
	return result_id

func snapshot() -> Dictionary:
	return {"quantities": _quantities.duplicate(true), "item_state": _item_state.duplicate(true)}

func restore(snapshot_data: Dictionary) -> void:
	_quantities = snapshot_data.get("quantities", {}).duplicate(true)
	_item_state = snapshot_data.get("item_state", {}).duplicate(true)
