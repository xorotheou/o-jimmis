extends Node
## Deterministic story authority for flags, variables, and world-state values.

signal flag_changed(flag_id: StringName, enabled: bool)
signal variable_changed(variable_id: StringName, value: Variant)

var _flags: Dictionary = {}
var _variables: Dictionary = {}
var _world_state: Dictionary = {}

func set_flag(flag_id: StringName, enabled: bool = true) -> void:
	assert(not flag_id.is_empty(), "Story flag id must not be empty")
	_flags[flag_id] = enabled
	flag_changed.emit(flag_id, enabled)

func has_flag(flag_id: StringName) -> bool:
	return bool(_flags.get(flag_id, false))

func set_variable(variable_id: StringName, value: Variant) -> void:
	assert(not variable_id.is_empty(), "Story variable id must not be empty")
	_variables[variable_id] = value
	variable_changed.emit(variable_id, value)

func get_variable(variable_id: StringName, fallback: Variant = null) -> Variant:
	return _variables.get(variable_id, fallback)

func set_world_state(state_id: StringName, value: Variant) -> void:
	_world_state[state_id] = value

func get_world_state(state_id: StringName, fallback: Variant = null) -> Variant:
	return _world_state.get(state_id, fallback)

func snapshot() -> Dictionary:
	return {"flags": _flags.duplicate(true), "variables": _variables.duplicate(true), "world_state": _world_state.duplicate(true)}

func restore(snapshot_data: Dictionary) -> void:
	_flags = snapshot_data.get("flags", {}).duplicate(true)
	_variables = snapshot_data.get("variables", {}).duplicate(true)
	_world_state = snapshot_data.get("world_state", {}).duplicate(true)
