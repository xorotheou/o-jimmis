class_name AdventureActionExecutor
extends RefCounted
## Executes a deliberately small, deterministic data-action vocabulary.

static func execute(actions: Array[Dictionary]) -> bool:
	for action in actions:
		match StringName(action.get("type", "")):
			&"set_flag": Story.set_flag(StringName(action.get("id", "")), bool(action.get("value", true)))
			&"set_variable": Story.set_variable(StringName(action.get("id", "")), action.get("value"))
			&"add_item":
				if not Inventory.add_item(StringName(action.get("id", "")), int(action.get("quantity", 1))): return false
			&"remove_item":
				if not Inventory.remove_item(StringName(action.get("id", "")), int(action.get("quantity", 1))): return false
			_:
				Log.error("adventure", "Unknown deterministic action", action)
				return false
	return true
