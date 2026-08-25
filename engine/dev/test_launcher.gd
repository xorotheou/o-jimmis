extends Control
## Simple in-editor launcher for the reusable test world and smoke harnesses.

const TEST_WORLD := "res://content/test_environment/world_test.tscn"
const SMOKE_WORLD := "res://tests/smoke_world_test.tscn"
const SMOKE_SAVE := "res://tests/smoke_save_test.tscn"
const SMOKE_INTERACTION := "res://tests/smoke_interaction_test.tscn"
const SMOKE_INVENTORY := "res://tests/smoke_inventory_test.tscn"
const SMOKE_QUEST := "res://tests/smoke_quest_test.tscn"

@onready var _run_log_status: Label = $LogPanel/VBox/RunLogStatus
@onready var _run_log_view: RichTextLabel = $LogPanel/VBox/ScrollContainer/RunLogViewer

func _ready() -> void:
	_update_status()
	$Panel/VBox/OpenWorld.pressed.connect(_on_open_world_pressed)
	$Panel/VBox/OpenSmokeWorld.pressed.connect(_on_open_smoke_world_pressed)
	$Panel/VBox/OpenSmokeSave.pressed.connect(_on_open_smoke_save_pressed)
	$Panel/VBox/OpenSmokeInteraction.pressed.connect(_on_open_smoke_interaction_pressed)
	$Panel/VBox/OpenSmokeInventory.pressed.connect(_on_open_smoke_inventory_pressed)
	$Panel/VBox/OpenSmokeQuest.pressed.connect(_on_open_smoke_quest_pressed)
	$Panel/VBox/Quit.pressed.connect(_on_quit_pressed)
	$LogPanel/VBox/RefreshRunLogs.pressed.connect(_refresh_run_logs)
	_refresh_run_logs()
	if _is_headless_runtime():
		call_deferred("_quit_if_headless")

func _update_status() -> void:
	var status := $Panel/VBox/Status
	status.text = "Open the reusable adventure test world or launch a smoke scene."

func _on_open_world_pressed() -> void:
	get_tree().change_scene_to_file(TEST_WORLD)

func _on_open_smoke_world_pressed() -> void:
	get_tree().change_scene_to_file(SMOKE_WORLD)

func _on_open_smoke_save_pressed() -> void:
	get_tree().change_scene_to_file(SMOKE_SAVE)

func _on_open_smoke_interaction_pressed() -> void:
	get_tree().change_scene_to_file(SMOKE_INTERACTION)

func _on_open_smoke_inventory_pressed() -> void:
	get_tree().change_scene_to_file(SMOKE_INVENTORY)

func _on_open_smoke_quest_pressed() -> void:
	get_tree().change_scene_to_file(SMOKE_QUEST)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _quit_if_headless() -> void:
	if _is_headless_runtime():
		get_tree().quit()

func _is_headless_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"

func _refresh_run_logs() -> void:
	var summaries := Log.get_recent_run_summaries()
	if summaries.is_empty():
		_run_log_status.text = "No run logs have been captured yet."
		_run_log_view.text = "Start the project or run a smoke test to capture the first run."
		return
	var lines: Array[String] = []
	lines.append("Last two runs")
	lines.append("")
	_run_log_status.text = "Showing %d run(s) from %s" % [summaries.size(), String(Log.get_run_log_paths().front())]
	for index in summaries.size():
		lines.append(_format_run_summary(summaries[index], index + 1))
		lines.append("")
	_run_log_view.text = "\n".join(lines).strip_edges()

func _format_run_summary(summary: Dictionary, index: int) -> String:
	var session: Dictionary = summary.get("session", {})
	var last_entry: Dictionary = summary.get("last_entry", {})
	var lines: Array[String] = []
	lines.append("%d. %s" % [index, String(session.get("label", "run"))])
	lines.append("   status: %s" % String(session.get("status", "")))
	lines.append("   entries: %d" % int(summary.get("entry_count", 0)))
	lines.append("   run id: %s" % String(session.get("run_id", "")))
	lines.append("   scene: %s" % String(session.get("tree", {}).get("current_scene_path", "")))
	lines.append("   location: %s" % String(session.get("tree", {}).get("world_location_id", "")))
	lines.append("   log paths: %s -> %s" % [
		String(session.get("paths", {}).get("previous", "")),
		String(session.get("paths", {}).get("current", "")),
	])
	if not last_entry.is_empty():
		lines.append("   last entry: [%s] %s: %s" % [
			String(last_entry.get("level", "")),
			String(last_entry.get("scope", "")),
			String(last_entry.get("message", "")),
		])
	return "\n".join(lines)
