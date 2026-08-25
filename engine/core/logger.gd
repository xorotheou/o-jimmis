extends Node
## Structured logger that emits testable messages without coupling to a UI.

signal message_logged(entry: Dictionary)

const LEVELS := {"debug": 10, "info": 20, "warning": 30, "error": 40}
var entries: Array[Dictionary] = []

func debug(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("debug", scope, message, metadata)
func info(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("info", scope, message, metadata)
func warning(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("warning", scope, message, metadata)
func error(scope: String, message: String, metadata: Dictionary = {}) -> void:
	write("error", scope, message, metadata)

func write(level: String, scope: String, message: String, metadata: Dictionary = {}) -> void:
	assert(LEVELS.has(level), "Unknown log level: %s" % level)
	var entry := {"level": level, "scope": scope, "message": message, "metadata": metadata, "time_msec": Time.get_ticks_msec()}
	entries.append(entry)
	if LEVELS[level] >= LEVELS.get(EngineConfig.get_value("logging/minimum_level", "info"), 20):
		print("[%s] %s: %s" % [level.to_upper(), scope, message])
	message_logged.emit(entry)

func clear() -> void:
	entries.clear()
