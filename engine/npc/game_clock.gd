extends Node
## Deterministic game clock; schedules query this instead of wall-clock time.

signal time_changed(minutes_since_midnight: int)
var minutes_since_midnight := 480

func set_time(minutes: int) -> void:
	minutes_since_midnight = posmod(minutes, 1440)
	time_changed.emit(minutes_since_midnight)

func advance(minutes: int) -> void:
	set_time(minutes_since_midnight + minutes)
