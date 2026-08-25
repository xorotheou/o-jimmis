extends Node
## Developer-only inspection and mutation facade; never used as gameplay authority.

func set_state_value(key: StringName, value: Variant) -> void:
	GameState.set_value(key, value)
	GameEvents.debug_command_executed.emit(&"set_state_value")

func inspect_state() -> Dictionary:
	return {
		"game": GameState.snapshot(),
		"story": Story.snapshot(),
		"inventory": Inventory.snapshot(),
		"puzzles": Puzzles.snapshot(),
		"quests": Quests.snapshot(),
		"npcs": Npcs.snapshot(),
		"time": Clock.minutes_since_midnight,
		"location": World.current_location_id,
		"logs": Log.get_recent_run_summaries(),
	}

func set_ai_enabled(enabled: bool) -> void:
	ProjectSettings.set_setting(EngineConfig.PREFIX + "ai/enabled", enabled)
	GameEvents.debug_command_executed.emit(&"set_ai_enabled")

func is_ai_enabled() -> bool:
	return bool(EngineConfig.get_value("ai/enabled", false))
