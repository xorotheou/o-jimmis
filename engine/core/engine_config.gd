extends Node
## Configuration with safe defaults. Projects may override keys in project settings.

const PREFIX := "adventure_engine/"
const DEFAULTS := {
	"debug/enabled": true,
	"logging/minimum_level": "info",
	"save/version": 1,
	"ai/enabled": false,
}

func _ready() -> void:
	for key: String in DEFAULTS:
		var full_key := PREFIX + key
		if not ProjectSettings.has_setting(full_key):
			ProjectSettings.set_setting(full_key, DEFAULTS[key])

func get_value(key: String, fallback: Variant = null) -> Variant:
	var full_key := PREFIX + key
	return ProjectSettings.get_setting(full_key, DEFAULTS.get(key, fallback))
