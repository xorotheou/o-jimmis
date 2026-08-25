extends Node

const Support = preload("res://tests/phase5_test_support.gd")

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	Support.register_content()
	Inventory.add_item(&"old_wire")
	Inventory.add_item(&"electrical_fuse")
	Inventory.add_item(&"broken_hook")
	Inventory.add_item(&"rope")
	Inventory.add_item(&"church_key")
	Inventory.add_item(&"pliers")

	_assert(Inventory.combine(&"old_wire", &"electrical_fuse") == &"repaired_fuse", "Wire and fuse did not combine.")
	_assert(Inventory.has_item(&"repaired_fuse"), "Combined fuse result is missing.")
	_assert(not Inventory.has_item(&"old_wire"), "Old wire should have been consumed.")
	_assert(not Inventory.has_item(&"electrical_fuse"), "Electrical fuse should have been consumed.")

	_assert(Inventory.combine(&"broken_hook", &"rope") == &"retrieval_hook", "Hook and rope did not combine.")
	_assert(Inventory.has_item(&"retrieval_hook"), "Retrieval hook result is missing.")

	var before_invalid := Inventory.snapshot()
	_assert(Inventory.combine(&"church_key", &"pliers").is_empty(), "Invalid combination should fail.")
	_assert(Inventory.snapshot() == before_invalid, "Invalid combination changed inventory state.")

	var before_missing := Inventory.snapshot()
	_assert(Inventory.combine(&"cafe_receipt", &"church_key").is_empty(), "Missing source item should fail.")
	_assert(Inventory.snapshot() == before_missing, "Missing source item changed inventory state.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)
