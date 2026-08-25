class_name AdventureActionExecutor
extends RefCounted
## Executes a deliberately small, deterministic data-action vocabulary.

static func execute(actions: Array[Dictionary]) -> bool:
	var story_snapshot := Story.snapshot()
	var inventory_snapshot := Inventory.snapshot()
	var quest_snapshot := Quests.snapshot()
	var npc_snapshot := Npcs.snapshot()
	var puzzle_snapshot := Puzzles.snapshot()
	for action in actions:
		if not _execute_action(action):
			Story.restore(story_snapshot)
			Inventory.restore(inventory_snapshot)
			Quests.restore(quest_snapshot)
			Npcs.restore(npc_snapshot)
			Puzzles.restore(puzzle_snapshot)
			return false
	return true

static func _execute_action(action: Dictionary) -> bool:
	match StringName(action.get("type", "")):
		&"set_flag":
			Story.set_flag(StringName(action.get("id", "")), bool(action.get("value", true)))
			return true
		&"set_variable":
			Story.set_variable(StringName(action.get("id", "")), action.get("value"))
			return true
		&"add_item":
			return Inventory.add_item(StringName(action.get("id", "")), int(action.get("quantity", 1)))
		&"remove_item":
			return Inventory.remove_item(StringName(action.get("id", "")), int(action.get("quantity", 1)))
		&"start_quest":
			return Quests.start(StringName(action.get("id", "")))
		&"complete_objective":
			return Quests.complete_objective(StringName(action.get("quest_id", "")), StringName(action.get("objective_id", "")))
		&"change_relationship":
			Npcs.change_relationship(StringName(action.get("id", "")), int(action.get("delta", 0)))
			return true
		&"remember_npc":
			Npcs.remember(StringName(action.get("npc_id", "")), String(action.get("memory", "")))
			return true
		&"complete_puzzle":
			return Puzzles.complete(StringName(action.get("id", "")))
		_:
			Log.error("adventure", "Unknown deterministic action", action)
			return false
