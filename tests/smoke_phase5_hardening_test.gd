extends Node
## Headless runtime smoke test for the Phase 5A engine hardening fixes.

const SAVE_PATH := "user://phase5_hardening_test.json"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	_reset_runtime_state()
	_setup_host_scene()

	var location := AdventureLocationDefinition.new()
	location.location_id = &"phase5_hardening_location"
	location.scene_path = "res://tests/phase5_hardening_location.tscn"
	location.default_spawn_id = &"hardening_start"
	World.register_location(location)

	_assert(World.has_location_definition(&"phase5_hardening_location"), "Location definition was not registered.")
	_assert(not GameState.snapshot().has(&"world/location_definitions/phase5_hardening_location"), "Location definition leaked into GameState snapshot.")

	_assert(World.load_location(&"phase5_hardening_location", &"hardening_start"), "Valid location load failed.")
	_assert(World.current_location_id == &"phase5_hardening_location", "Current location id did not update.")
	_assert(_player.global_position.distance_to(Vector3(2.0, 0.0, 0.0)) < 0.25, "Player did not spawn at the authored spawn point.")

	var stored_definition: Variant = World.get_location_definition(&"phase5_hardening_location")
	_assert(stored_definition != null, "Stored location definition was missing.")
	_assert(String(stored_definition.scene_path) == "res://tests/phase5_hardening_location.tscn", "Stored location definition changed unexpectedly.")
	_assert(not GameState.snapshot().has(&"world/location_definitions/phase5_hardening_location"), "Location definition appeared in GameState after load.")

	_prepare_shared_content()
	_test_action_transaction()
	_test_inventory_combinations()
	_test_save_restore_failure()

	_cleanup_save_file()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _setup_host_scene() -> void:
	_host = Node3D.new()
	_host.name = "Phase5HardeningHost"
	get_tree().root.add_child(_host)
	get_tree().current_scene = _host

	_player = AdventurePlayerController.new()
	_player.name = "Phase5HardeningPlayer"
	var navigation_agent := NavigationAgent3D.new()
	navigation_agent.name = "NavigationAgent3D"
	_player.add_child(navigation_agent)
	_host.add_child(_player)

func _prepare_shared_content() -> void:
	var wire := AdventureItemDefinition.new()
	wire.item_id = &"phase5_wire"
	wire.display_name = "Wire"
	wire.stackable = false
	wire.inspection_text = "A short length of salvage wire."
	wire.combination_results = {&"phase5_module": &"phase5_fixed_module"}

	var module := AdventureItemDefinition.new()
	module.item_id = &"phase5_module"
	module.display_name = "Module"
	module.stackable = false
	module.inspection_text = "A small electrical module."

	var fixed_module := AdventureItemDefinition.new()
	fixed_module.item_id = &"phase5_fixed_module"
	fixed_module.display_name = "Fixed Module"
	fixed_module.stackable = false
	fixed_module.inspection_text = "A repaired electrical module."

	var scrap := AdventureItemDefinition.new()
	scrap.item_id = &"phase5_scrap"
	scrap.display_name = "Scrap"
	scrap.stackable = false
	scrap.combination_results = {&"phase5_bolt": &"phase5_widget"}

	var bolt := AdventureItemDefinition.new()
	bolt.item_id = &"phase5_bolt"
	bolt.display_name = "Bolt"
	bolt.stackable = false

	var widget := AdventureItemDefinition.new()
	widget.item_id = &"phase5_widget"
	widget.display_name = "Widget"
	widget.stackable = false

	Inventory.register_definition(wire)
	Inventory.register_definition(module)
	Inventory.register_definition(fixed_module)
	Inventory.register_definition(scrap)
	Inventory.register_definition(bolt)
	Inventory.register_definition(widget)

func _test_action_transaction() -> void:
	Story.restore({})
	Inventory.restore({})

	_assert(Inventory.add_item(&"phase5_wire"), "Wire was not added for the action transaction test.")
	Story.set_flag(&"phase5_transaction_flag", false)
	Story.set_variable(&"phase5_transaction_value", "before")

	var actions: Array[Dictionary] = []
	actions.append({"type": "set_flag", "id": "phase5_transaction_flag", "value": true})
	actions.append({"type": "set_variable", "id": "phase5_transaction_value", "value": "after"})
	actions.append({"type": "remove_item", "id": "phase5_wire", "quantity": 1})
	actions.append({"type": "add_item", "id": "phase5_missing_result", "quantity": 1})

	_assert(not AdventureActionExecutor.execute(actions), "Transactional action batch should have failed.")
	_assert(not Story.has_flag(&"phase5_transaction_flag"), "Story flag was not rolled back.")
	_assert(String(Story.get_variable(&"phase5_transaction_value", "")) == "before", "Story variable was not rolled back.")
	_assert(Inventory.has_item(&"phase5_wire"), "Inventory item was not rolled back.")

func _test_inventory_combinations() -> void:
	Inventory.restore({})
	_assert(Inventory.add_item(&"phase5_wire"), "Wire was not added for the successful combination test.")
	_assert(Inventory.add_item(&"phase5_module"), "Module was not added for the successful combination test.")
	_assert(Inventory.combine(&"phase5_wire", &"phase5_module") == &"phase5_fixed_module", "Successful inventory combination returned the wrong result.")
	_assert(not Inventory.has_item(&"phase5_wire"), "Successful inventory combination did not consume the first input.")
	_assert(not Inventory.has_item(&"phase5_module"), "Successful inventory combination did not consume the second input.")
	_assert(Inventory.has_item(&"phase5_fixed_module"), "Successful inventory combination did not add the result.")

	Inventory.restore({})
	_assert(Inventory.add_item(&"phase5_scrap"), "Scrap was not added for the failing combination test.")
	_assert(Inventory.add_item(&"phase5_bolt"), "Bolt was not added for the failing combination test.")
	_assert(Inventory.add_item(&"phase5_widget"), "Widget was not added to force the failing combination test.")
	var snapshot := Inventory.snapshot()
	_assert(Inventory.combine(&"phase5_scrap", &"phase5_bolt") == &"", "Failing inventory combination should not return a result.")
	_assert(Inventory.snapshot() == snapshot, "Failing inventory combination mutated state.")

func _test_save_restore_failure() -> void:
	Story.restore({})
	Inventory.restore({})
	GameState.set_value(&"phase5_marker", "before")
	Story.set_flag(&"phase5_story_flag", true)
	Inventory.set_item_state(&"phase5_widget", {"state": "before"})
	_assert(Inventory.add_item(&"phase5_widget"), "Widget was not added for the save restore test.")

	var payload := {
		"version": 1,
		"location_id": "phase5_missing_location",
		"game_state": {"phase5_marker": "after"},
		"story": {"flags": {"phase5_story_flag": false}, "variables": {}, "world_state": {}},
		"inventory": {"quantities": {"phase5_widget": 0}, "item_state": {"phase5_widget": {"state": "after"}}},
		"puzzles": {},
		"quests": {},
		"npcs": {},
		"time": 111,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	_assert(file != null, "Could not create the malformed save file.")
	file.store_string(JSON.stringify(payload))
	file.close()

	_assert(Save.load_game(SAVE_PATH) == FAILED, "Loading a save with a missing location should fail.")
	_assert(String(GameState.get_value(&"phase5_marker", "")) == "before", "GameState changed after failed restore.")
	_assert(Story.has_flag(&"phase5_story_flag"), "Story flag changed after failed restore.")
	_assert(Inventory.has_item(&"phase5_widget"), "Inventory changed after failed restore.")
	_assert(World.current_location_id == &"phase5_hardening_location", "Current location changed after failed restore.")
	_assert(String(World.get_location_definition(&"phase5_hardening_location").scene_path) == "res://tests/phase5_hardening_location.tscn", "Location definition changed after failed restore.")

func _cleanup_save_file() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _reset_runtime_state() -> void:
	World.unload_current_location()
	GameState.reset()
	Story.restore({})
	Inventory.restore({})
	Puzzles.restore({})
	Quests.restore({})
	Npcs.restore({})
	Clock.set_time(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

var _host: Node3D
var _player: AdventurePlayerController
