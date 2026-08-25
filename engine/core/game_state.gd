extends Node
## Minimal serializable state store. Domain systems own schemas above this generic layer.

var _values: Dictionary = {}

func set_value(key: StringName, value: Variant) -> void:
	assert(not key.is_empty(), "State key must not be empty")
	_values[key] = value
	GameEvents.state_changed.emit(key, value)

func get_value(key: StringName, fallback: Variant = null) -> Variant:
	return _values.get(key, fallback)

func has_value(key: StringName) -> bool:
	return _values.has(key)

func erase_value(key: StringName) -> void:
	_values.erase(key)

func snapshot() -> Dictionary:
	return _values.duplicate(true)

func restore(snapshot_data: Dictionary) -> void:
	_values = snapshot_data.duplicate(true)

func reset() -> void:
	_values.clear()
