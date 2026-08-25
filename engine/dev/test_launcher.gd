extends Control
## Simple in-editor launcher for the reusable test world and smoke harnesses.

const TEST_WORLD := "res://content/test_environment/world_test.tscn"
const SMOKE_WORLD := "res://tests/smoke_world_test.tscn"
const SMOKE_SAVE := "res://tests/smoke_save_test.tscn"
const SMOKE_INTERACTION := "res://tests/smoke_interaction_test.tscn"
const SMOKE_INVENTORY := "res://tests/smoke_inventory_test.tscn"
const SMOKE_QUEST := "res://tests/smoke_quest_test.tscn"

@onready var _run_log_status: Label = $LogPanel/VBox/RunLogStatus
@onready var _run_log_query: LineEdit = $LogPanel/VBox/FilterRow/RunLogQuery
@onready var _errors_only: CheckButton = $LogPanel/VBox/FilterRow/ErrorsOnly
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
	$LogPanel/VBox/FilterRow/ApplyFilter.pressed.connect(_refresh_run_logs)
	$LogPanel/VBox/FilterRow/ClearFilter.pressed.connect(_clear_filters)
	$LogPanel/VBox/FilterRow/RunLogQuery.text_submitted.connect(_on_query_submitted)
	$LogPanel/VBox/FilterRow/RunLogQuery.text_changed.connect(_on_query_changed)
	$LogPanel/VBox/FilterRow/ErrorsOnly.toggled.connect(_on_filter_toggled)
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
	var records := Log.get_recent_run_records()
	var query := _run_log_query.text.strip_edges().to_lower()
	var errors_only := _errors_only.button_pressed
	if records.is_empty():
		_run_log_status.text = "No run logs have been captured yet."
		_run_log_view.text = "Start the project or run a smoke test to capture the first run."
		return
	var rendered := _build_run_log_text(records, query, errors_only)
	_run_log_status.text = rendered.get("status", "")
	_run_log_view.text = rendered.get("text", "")

func _on_query_submitted(_text: String) -> void:
	_refresh_run_logs()

func _on_query_changed(_text: String) -> void:
	_refresh_run_logs()

func _on_filter_toggled(_pressed: bool) -> void:
	_refresh_run_logs()

func _clear_filters() -> void:
	_run_log_query.text = ""
	_errors_only.button_pressed = false
	_refresh_run_logs()

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

func _build_run_log_text(records: Array[Dictionary], query: String, errors_only: bool) -> Dictionary:
	var lines: Array[String] = []
	var matched_runs := 0
	lines.append("Last two runs")
	lines.append("")
	for index in records.size():
		var record: Dictionary = records[index]
		var summary := _summarize_record(record)
		var matching_entries := _filter_entries(record.get("entries", []), query, errors_only)
		if query != "" or errors_only:
			if matching_entries.is_empty() and not _record_matches_summary(summary, query):
				continue
		matched_runs += 1
		lines.append(_format_run_summary(summary, index + 1))
		if query != "" or errors_only:
			lines.append("   matching entries: %d" % matching_entries.size())
			for entry in matching_entries:
				lines.append(_format_entry(entry))
		lines.append("")
	var status := "Showing %d run(s) from %s" % [matched_runs, String(Log.get_run_log_paths().front())]
	if query != "" or errors_only:
		var filters: Array[String] = []
		if query != "":
			filters.append("query '%s'" % query)
		if errors_only:
			filters.append("errors only")
		status += " filtered by %s" % ", ".join(filters)
	if matched_runs == 0:
		status = "No runs matched the current filter."
		lines = ["No runs matched the current filter.", "", "Try a broader text query or clear the filters."]
	return {"status": status, "text": "\n".join(lines).strip_edges()}

func _summarize_record(record: Dictionary) -> Dictionary:
	return {
		"session": record.get("session", {}),
		"entry_count": int(record.get("entries", []).size()),
		"last_entry": record.get("entries", [{}]).back() if not record.get("entries", []).is_empty() else {},
	}

func _filter_entries(entries: Array, query: String, errors_only: bool) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		var level := String(entry.get("level", ""))
		var text := " ".join([
			level,
			String(entry.get("scope", "")),
			String(entry.get("message", "")),
			JSON.stringify(entry.get("metadata", {})),
		]).to_lower()
		if errors_only and level != "error":
			continue
		if query != "" and query not in text:
			continue
		filtered.append(entry)
	return filtered

func _record_matches_summary(summary: Dictionary, query: String) -> bool:
	if query == "":
		return true
	var session: Dictionary = summary.get("session", {})
	var last_entry: Dictionary = summary.get("last_entry", {})
	var summary_text := " ".join([
		String(session.get("label", "")),
		String(session.get("status", "")),
		String(session.get("run_id", "")),
		String(session.get("tree", {}).get("current_scene_path", "")),
		String(session.get("tree", {}).get("world_location_id", "")),
		String(last_entry.get("scope", "")),
		String(last_entry.get("message", "")),
		JSON.stringify(last_entry.get("metadata", {})),
	]).to_lower()
	return query in summary_text

func _format_entry(entry: Dictionary) -> String:
	var metadata := JSON.stringify(entry.get("metadata", {}))
	return "   - [%s] %s: %s %s" % [
		String(entry.get("level", "")),
		String(entry.get("scope", "")),
		String(entry.get("message", "")),
		metadata,
	]
