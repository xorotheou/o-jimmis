extends Node
## Structured logger that emits testable messages without coupling to a UI.

signal message_logged(entry: Dictionary)
signal run_session_started(session: Dictionary)
signal run_session_finished(session: Dictionary)

const LEVELS := {"debug": 10, "info": 20, "warning": 30, "error": 40}
const RUN_LOG_FILE_CURRENT := "run_current.json"
const RUN_LOG_FILE_PREVIOUS := "run_previous.json"
const RUN_LOG_MAX := 2

var entries: Array[Dictionary] = []
var _run_log_dir := "user://logs"
var _run_log_current_path := "user://logs/run_current.json"
var _run_log_previous_path := "user://logs/run_previous.json"
var _session: Dictionary = {}
var _session_active := false

func debug(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("debug", scope, message, metadata)
func info(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("info", scope, message, metadata)
func warning(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("warning", scope, message, metadata)
func error(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("error", scope, message, metadata)

func _ready() -> void:
	_configure_run_log_dir(String(EngineConfig.get_value("logging/run_log_dir", "user://logs")))
	_begin_run_session("startup")
	if not tree_exiting.is_connected(_on_tree_exiting):
		tree_exiting.connect(_on_tree_exiting)

func write(level: String, scope: String, message: String, metadata: Dictionary = {}) -> void:
	assert(LEVELS.has(level), "Unknown log level: %s" % level)
	if not _session_active:
		_begin_run_session("auto")
	var entry := {
		"level": level,
		"scope": scope,
		"message": message,
		"metadata": _json_safe(metadata),
		"time_msec": Time.get_ticks_msec(),
		"context": _capture_context(),
		"run_id": _session.get("run_id", ""),
	}
	entries.append(entry)
	_session["entry_count"] = entries.size()
	_session["last_entry"] = entry
	if LEVELS[level] >= LEVELS.get(EngineConfig.get_value("logging/minimum_level", "info"), 20):
		print("[%s] %s: %s" % [level.to_upper(), scope, message])
	_persist_session()
	message_logged.emit(entry)

func clear() -> void:
	entries.clear()
	_session["entry_count"] = 0
	_session["last_entry"] = {}
	_persist_session()

func finish_run_session(status: String = "finished") -> void:
	if not _session_active:
		return
	_session["status"] = status
	_session["ended_at_msec"] = Time.get_ticks_msec()
	_session["ended_at_unix"] = Time.get_unix_time_from_system()
	_session_active = false
	_persist_session()
	run_session_finished.emit(_session.duplicate(true))

func reconfigure_run_log_dir(run_log_dir: String) -> void:
	_configure_run_log_dir(run_log_dir)
	_begin_run_session("reconfigured")

func begin_run_session(label: String = "") -> void:
	_begin_run_session(label)

func get_run_log_paths() -> Array[String]:
	return [_run_log_current_path, _run_log_previous_path]

func get_recent_run_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for path in get_run_log_paths():
		if not FileAccess.file_exists(path):
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			summaries.append(_summarize_run(parsed))
	return summaries

func _configure_run_log_dir(run_log_dir: String) -> void:
	_run_log_dir = run_log_dir if not run_log_dir.is_empty() else "user://logs"
	_run_log_current_path = _run_log_dir.path_join(RUN_LOG_FILE_CURRENT)
	_run_log_previous_path = _run_log_dir.path_join(RUN_LOG_FILE_PREVIOUS)
	_ensure_run_log_dir()

func _begin_run_session(label: String) -> void:
	_archive_current_run()
	entries.clear()
	_session = {
		"run_id": "%s-%s" % [OS.get_process_id(), Time.get_unix_time_from_system()],
		"label": label,
		"status": "running",
		"started_at_msec": Time.get_ticks_msec(),
		"started_at_unix": Time.get_unix_time_from_system(),
		"entry_count": 0,
		"paths": {
			"run_log_dir": _run_log_dir,
			"current": _run_log_current_path,
			"previous": _run_log_previous_path,
		},
		"process": _capture_process_context(),
	}
	_session_active = true
	_persist_session()
	run_session_started.emit(_session.duplicate(true))

func _ensure_run_log_dir() -> void:
	var absolute_dir := ProjectSettings.globalize_path(_run_log_dir)
	DirAccess.make_dir_recursive_absolute(absolute_dir)

func _archive_current_run() -> void:
	if not FileAccess.file_exists(_run_log_current_path):
		return
	var file := FileAccess.open(_run_log_current_path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		var archived: Dictionary = parsed.duplicate(true)
		var session: Dictionary = archived.get("session", {})
		if session.get("status", "") == "running":
			session["status"] = "interrupted"
			session["ended_at_msec"] = Time.get_ticks_msec()
			session["ended_at_unix"] = Time.get_unix_time_from_system()
		archived["session"] = session
		_write_json_file(_run_log_previous_path, archived)

func _persist_session() -> void:
	if _session.is_empty():
		return
	_session["entry_count"] = entries.size()
	_session["updated_at_msec"] = Time.get_ticks_msec()
	_session["updated_at_unix"] = Time.get_unix_time_from_system()
	_session["tree"] = _capture_tree_context()
	_session["last_level"] = entries.back().get("level", "") if not entries.is_empty() else ""
	_session["last_scope"] = entries.back().get("scope", "") if not entries.is_empty() else ""
	_write_json_file(_run_log_current_path, {"session": _session.duplicate(true), "entries": entries.duplicate(true)})

func _write_json_file(path: String, payload: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(payload))
	file.close()

func _capture_context() -> Dictionary:
	return {
		"process": _capture_process_context(),
		"tree": _capture_tree_context(),
	}

func _capture_process_context() -> Dictionary:
	return {
		"pid": OS.get_process_id(),
		"executable_path": OS.get_executable_path(),
		"headless": OS.has_feature("headless"),
		"run_log_dir": _run_log_dir,
	}

func _capture_tree_context() -> Dictionary:
	var tree := get_tree()
	var current_scene := tree.current_scene if tree != null else null
	var scene_path := ""
	var scene_name := ""
	if current_scene != null:
		scene_name = current_scene.name
		scene_path = String(current_scene.scene_file_path)
	return {
		"paused": tree.paused if tree != null else false,
		"current_scene_name": scene_name,
		"current_scene_path": scene_path,
		"current_scene_tree_path": String(current_scene.get_path()) if current_scene != null else "",
		"world_location_id": String(World.current_location_id),
	}

func _summarize_run(run_payload: Dictionary) -> Dictionary:
	var session: Dictionary = run_payload.get("session", {})
	var entries_payload: Array = run_payload.get("entries", [])
	return {
		"session": session,
		"entry_count": entries_payload.size(),
		"last_entry": entries_payload.back() if not entries_payload.is_empty() else {},
	}

func _json_safe(value: Variant) -> Variant:
	if value is Dictionary:
		var output: Dictionary = {}
		for key in value.keys():
			output[String(key)] = _json_safe(value[key])
		return output
	if value is Array:
		var output_array: Array = []
		for item in value:
			output_array.append(_json_safe(item))
		return output_array
	if value is StringName or value is NodePath:
		return String(value)
	if value is Vector2 or value is Vector3 or value is Vector4 or value is Color or value is Rect2 or value is Rect2i or value is Vector2i or value is Vector3i:
		return str(value)
	return value

func _on_tree_exiting() -> void:
	finish_run_session("finished")
