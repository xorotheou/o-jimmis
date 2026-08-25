extends Node
## Headless runtime smoke test for rolling two-run log retention.

const LOG_DIR := "user://smoke_run_logs"
const CURRENT_LOG := "user://smoke_run_logs/run_current.json"
const PREVIOUS_LOG := "user://smoke_run_logs/run_previous.json"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	_cleanup_logs()
	Log.reconfigure_run_log_dir(LOG_DIR)

	Log.info("smoke/logging", "first run", {"phase": "first", "path": CURRENT_LOG})
	Log.warning("smoke/logging", "first warning", {"tree": true})
	Log.finish_run_session("finished")

	_assert(FileAccess.file_exists(CURRENT_LOG), "Current run log was not created.")
	_assert(not Log.get_recent_run_summaries().is_empty(), "Run summaries were not available.")

	Log.begin_run_session("smoke_second")
	Log.error("smoke/logging", "second run", {"phase": "second", "path": PREVIOUS_LOG})
	Log.finish_run_session("finished")

	_assert(FileAccess.file_exists(CURRENT_LOG), "Current run log was missing after rotation.")
	_assert(FileAccess.file_exists(PREVIOUS_LOG), "Previous run log was missing after rotation.")

	var current := _read_json(CURRENT_LOG)
	var previous := _read_json(PREVIOUS_LOG)

	_assert(String(current.get("session", {}).get("status", "")) == "finished", "Current run session was not marked finished.")
	_assert(String(previous.get("session", {}).get("status", "")) == "finished", "Previous run session was not archived as finished.")
	_assert(int(current.get("session", {}).get("entry_count", 0)) > 0, "Current run log should contain entries.")
	_assert(int(previous.get("session", {}).get("entry_count", 0)) > 0, "Previous run log should contain entries.")
	_assert(String(current.get("entries", [{}]).back().get("scope", "")) == "smoke/logging", "Current run did not keep the latest scope.")
	_assert(String(previous.get("entries", [{}]).back().get("scope", "")) == "smoke/logging", "Previous run did not keep the first scope.")
	_assert(String(current.get("session", {}).get("paths", {}).get("run_log_dir", "")) == LOG_DIR, "Current run log dir was wrong.")
	_assert(String(previous.get("session", {}).get("paths", {}).get("run_log_dir", "")) == LOG_DIR, "Previous run log dir was wrong.")

	_cleanup_logs()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func _cleanup_logs() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(CURRENT_LOG))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PREVIOUS_LOG))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LOG_DIR))

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
