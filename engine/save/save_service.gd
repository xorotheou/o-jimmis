extends Node
## Versioned JSON save envelope. Migration is explicit and deterministic.

const CURRENT_VERSION := 1
signal save_completed(path: String)
signal load_completed(path: String)

func save_game(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(_build_payload()))
	file.close()
	save_completed.emit(path)
	return OK

func load_game(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return FileAccess.get_open_error()
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary: return ERR_FILE_CORRUPT
	var payload := _migrate(parsed)
	if payload.is_empty(): return ERR_FILE_UNRECOGNIZED
	if not _restore(payload):
		return FAILED
	load_completed.emit(path)
	return OK

func _build_payload() -> Dictionary:
	return {"version": CURRENT_VERSION, "location_id": World.current_location_id, "spawn_id": World.current_spawn_id, "game_state": GameState.snapshot(), "story": Story.snapshot(), "inventory": Inventory.snapshot(), "puzzles": Puzzles.snapshot(), "quests": Quests.snapshot(), "npcs": Npcs.snapshot(), "time": Clock.minutes_since_midnight}

func _restore(payload: Dictionary) -> bool:
	var location_id := StringName(payload.get("location_id", ""))
	var spawn_id := StringName(payload.get("spawn_id", ""))
	if not location_id.is_empty():
		if not World.has_location_definition(location_id):
			Log.error("save", "Save references unknown location", {"location_id": location_id})
			return false
		if not World.load_location(location_id, spawn_id):
			Log.error("save", "Failed to restore location from save", {"location_id": location_id})
			return false
	GameState.restore(payload.get("game_state", {}))
	Story.restore(payload.get("story", {}))
	Inventory.restore(payload.get("inventory", {}))
	Puzzles.restore(payload.get("puzzles", {}))
	Quests.restore(payload.get("quests", {}))
	Npcs.restore(payload.get("npcs", {}))
	Clock.set_time(int(payload.get("time", 480)))
	return true

func _migrate(payload: Dictionary) -> Dictionary:
	var version := int(payload.get("version", 0))
	if version != CURRENT_VERSION:
		Log.error("save", "Unsupported save version", {"version": version})
		return {}
	return payload
