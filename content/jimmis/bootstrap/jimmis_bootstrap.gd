class_name JimmisBootstrap
extends Node

const JIMMIS_CONTENT = preload("res://content/jimmis/bootstrap/jimmis_content.gd")
const PLAYER_CONTROLLER_SCRIPT = preload("res://engine/world/player_controller.gd")
const CLICK_TO_MOVE_CONTROLLER_SCRIPT = preload("res://engine/world/click_to_move_controller.gd")
const SAVE_PATH := "user://saves/jimmis_vertical_slice.json"
const START_LOCATION := &"village_square"
const START_SPAWN := &"square_west"

var _player: AdventurePlayerController
var _click_controller: AdventureClickToMoveController
var _ui_root: CanvasLayer
var _menu_panel: PanelContainer
var _pause_panel: PanelContainer
var _dialogue_panel: PanelContainer
var _dialogue_text: RichTextLabel
var _dialogue_choices: VBoxContainer
var _feedback_label: Label
var _location_label: Label
var _inventory_view: RichTextLabel
var _quest_view: RichTextLabel
var _state_view: RichTextLabel
var _active_dialogue_id: StringName = &""
var _active_dialogue_node_id: StringName = &""
var _active_camera_path: NodePath

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_register_services()
	JIMMIS_CONTENT.register_all()
	_build_world()
	_build_ui()
	_connect_signals()
	_show_menu()
	_refresh_views()
	Log.info("jimmis", "Jimmis vertical slice bootstrap ready")
	GameEvents.engine_ready.emit()

func _register_services() -> void:
	Services.register_service("events", GameEvents)
	Services.register_service("state", GameState)
	Services.register_service("config", EngineConfig)
	Services.register_service("logger", Log)
	Services.register_service("world", World)
	Services.register_service("story", Story)
	Services.register_service("inventory", Inventory)
	Services.register_service("interaction", Interaction)
	Services.register_service("dialogue", Dialogue)
	Services.register_service("puzzles", Puzzles)
	Services.register_service("quests", Quests)
	Services.register_service("npcs", Npcs)
	Services.register_service("save", Save)

func _build_world() -> void:
	var world_root := Node3D.new()
	world_root.name = "WorldRoot"
	add_child(world_root)

	_player = PLAYER_CONTROLLER_SCRIPT.new()
	_player.name = "Jimmy"
	_player.position = Vector3.ZERO

	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.2
	collision.shape = capsule
	_player.add_child(collision)

	if not OS.has_feature("headless"):
		var mesh := MeshInstance3D.new()
		var body_mesh := CapsuleMesh.new()
		body_mesh.radius = 0.28
		body_mesh.height = 1.2
		mesh.mesh = body_mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.85, 0.75, 0.62)
		mesh.material_override = material
		_player.add_child(mesh)

	var agent := NavigationAgent3D.new()
	agent.name = "NavigationAgent3D"
	agent.path_desired_distance = 0.15
	agent.target_desired_distance = 0.15
	_player.add_child(agent)

	world_root.add_child(_player)

	_click_controller = CLICK_TO_MOVE_CONTROLLER_SCRIPT.new()
	_click_controller.name = "ClickController"
	_click_controller.player_path = NodePath("../Jimmy")
	world_root.add_child(_click_controller)

func _build_ui() -> void:
	_ui_root = CanvasLayer.new()
	_ui_root.name = "UiRoot"
	_ui_root.layer = 20
	add_child(_ui_root)

	_menu_panel = _make_panel(Vector2(440.0, 240.0), Vector2(420.0, 220.0), "Jimmis Vertical Slice")
	_ui_root.add_child(_menu_panel)
	var menu_vbox := _panel_vbox(_menu_panel)
	_add_label(menu_vbox, "A playable adventure slice with 5 locations, 5 NPCs, inventory, dialogue, and save/load.")
	_add_button(menu_vbox, "New Game", Callable(self, "_on_new_game_pressed"))
	_add_button(menu_vbox, "Continue", Callable(self, "_on_continue_pressed"))
	_add_button(menu_vbox, "Settings", Callable(self, "_on_settings_pressed"))
	_add_button(menu_vbox, "Quit", Callable(self, "_on_quit_pressed"))

	_pause_panel = _make_panel(Vector2(440.0, 260.0), Vector2(420.0, 240.0), "Pause")
	_ui_root.add_child(_pause_panel)
	var pause_vbox := _panel_vbox(_pause_panel)
	_add_label(pause_vbox, "Paused. Save or resume.")
	_add_button(pause_vbox, "Resume", Callable(self, "_on_resume_pressed"))
	_add_button(pause_vbox, "Save", Callable(self, "_on_save_pressed"))
	_add_button(pause_vbox, "Load", Callable(self, "_on_load_pressed"))
	_add_button(pause_vbox, "Reload Location", Callable(self, "_on_reload_location_pressed"))
	_add_button(pause_vbox, "Quit", Callable(self, "_on_quit_pressed"))

	var hud_panel := _make_panel(Vector2(16.0, 16.0), Vector2(360.0, 300.0), "State")
	_ui_root.add_child(hud_panel)
	var hud_vbox := _panel_vbox(hud_panel)
	_location_label = _add_label(hud_vbox, "Location: -")
	_inventory_view = _add_rich_text(hud_vbox, "Inventory")
	_quest_view = _add_rich_text(hud_vbox, "Quest")

	var debug_panel := _make_panel(Vector2(16.0, 328.0), Vector2(360.0, 346.0), "Inspector")
	_ui_root.add_child(debug_panel)
	var debug_vbox := _panel_vbox(debug_panel)
	_state_view = _add_rich_text(debug_vbox, "Inspector")
	_add_button_row(debug_vbox, [
		{"text": "Teleport Square", "callable": Callable(self, "_on_teleport_square_pressed")},
		{"text": "Teleport Cafe", "callable": Callable(self, "_on_teleport_cafe_pressed")},
		{"text": "Teleport Church", "callable": Callable(self, "_on_teleport_church_pressed")},
	])
	_add_button_row(debug_vbox, [
		{"text": "Teleport Street", "callable": Callable(self, "_on_teleport_street_pressed")},
		{"text": "Give Wire", "callable": Callable(self, "_on_give_wire_pressed")},
		{"text": "Give Fuse", "callable": Callable(self, "_on_give_fuse_pressed")},
	])
	_add_button_row(debug_vbox, [
		{"text": "Give Hook", "callable": Callable(self, "_on_give_hook_pressed")},
		{"text": "Set Access", "callable": Callable(self, "_on_set_access_pressed")},
		{"text": "Reset Puzzle", "callable": Callable(self, "_on_reset_puzzle_pressed")},
	])
	_add_button_row(debug_vbox, [
		{"text": "Save", "callable": Callable(self, "_on_save_pressed")},
		{"text": "Load", "callable": Callable(self, "_on_load_pressed")},
		{"text": "Advance Time", "callable": Callable(self, "_on_advance_time_pressed")},
	])

	_dialogue_panel = _make_panel(Vector2(16.0, 690.0), Vector2(760.0, 190.0), "Dialogue")
	_ui_root.add_child(_dialogue_panel)
	var dialogue_vbox := _panel_vbox(_dialogue_panel)
	_dialogue_text = _add_rich_text(dialogue_vbox, "Dialogue text")
	_dialogue_choices = VBoxContainer.new()
	_dialogue_choices.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dialogue_vbox_add(dialogue_vbox, _dialogue_choices)
	_dialogue_panel.visible = false

	_feedback_label = _add_label(_ui_root, "")
	_feedback_label.position = Vector2(16.0, 650.0)
	_feedback_label.size = Vector2(760.0, 28.0)
	_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _connect_signals() -> void:
	if not GameEvents.location_requested.is_connected(Callable(World, "load_location")):
		GameEvents.location_requested.connect(World.load_location)
	if not GameEvents.interaction_requested.is_connected(Callable(Interaction, "resolve")):
		GameEvents.interaction_requested.connect(Interaction.resolve)
	if not World.location_loaded.is_connected(_on_location_loaded):
		World.location_loaded.connect(_on_location_loaded)
	if not World.location_unloaded.is_connected(_on_location_unloaded):
		World.location_unloaded.connect(_on_location_unloaded)
	if not Dialogue.conversation_started.is_connected(_on_conversation_started):
		Dialogue.conversation_started.connect(_on_conversation_started)
	if not Dialogue.dialogue_advanced.is_connected(_on_dialogue_advanced):
		Dialogue.dialogue_advanced.connect(_on_dialogue_advanced)
	if not Dialogue.conversation_ended.is_connected(_on_conversation_ended):
		Dialogue.conversation_ended.connect(_on_conversation_ended)
	if not Interaction.interaction_resolved.is_connected(_on_interaction_resolved):
		Interaction.interaction_resolved.connect(_on_interaction_resolved)
	if not Inventory.items_combined.is_connected(_on_items_combined):
		Inventory.items_combined.connect(_on_items_combined)
	if not Puzzles.puzzle_completed.is_connected(_on_puzzle_completed):
		Puzzles.puzzle_completed.connect(_on_puzzle_completed)
	if not Quests.objective_completed.is_connected(_on_objective_completed):
		Quests.objective_completed.connect(_on_objective_completed)
	if not Quests.quest_completed.is_connected(_on_quest_completed):
		Quests.quest_completed.connect(_on_quest_completed)
	if not Npcs.relationship_changed.is_connected(_on_relationship_changed):
		Npcs.relationship_changed.connect(_on_relationship_changed)
	if not Save.save_completed.is_connected(_on_save_completed):
		Save.save_completed.connect(_on_save_completed)
	if not Save.load_completed.is_connected(_on_load_completed):
		Save.load_completed.connect(_on_load_completed)
	if not GameEvents.camera_changed.is_connected(_on_camera_changed):
		GameEvents.camera_changed.connect(_on_camera_changed)

func _show_menu() -> void:
	_pause(false)
	_menu_panel.visible = true
	_pause_panel.visible = false
	_dialogue_panel.visible = false
	_feedback("Start a new game or continue from the last save.")

func _show_hud() -> void:
	_menu_panel.visible = false

func _pause(enabled: bool) -> void:
	get_tree().paused = enabled
	_pause_panel.visible = enabled

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _menu_panel.visible:
		_pause(not get_tree().paused)

func _on_new_game_pressed() -> void:
	_reset_runtime_state()
	_show_hud()
	if not World.load_location(START_LOCATION, START_SPAWN):
		_feedback("Failed to load the starting location.")
		return
	_feedback("New game started.")

func _on_continue_pressed() -> void:
	_show_hud()
	if not FileAccess.file_exists(SAVE_PATH):
		_feedback("No save found. Starting a new game instead.")
		_on_new_game_pressed()
		return
	var result := Save.load_game(SAVE_PATH)
	if result != OK:
		_feedback("Load failed: %s" % error_string(result))
		_show_menu()
		return
	_feedback("Game loaded.")

func _on_settings_pressed() -> void:
	_feedback("Settings are a placeholder in Phase 5.")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	_pause(false)

func _on_save_pressed() -> void:
	var dir := SAVE_PATH.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var result := Save.save_game(SAVE_PATH)
	if result == OK:
		_feedback("Game saved.")
	else:
		_feedback("Save failed: %s" % error_string(result))

func _on_load_pressed() -> void:
	_on_continue_pressed()

func _on_reload_location_pressed() -> void:
	if World.current_location_id.is_empty():
		_feedback("No location to reload.")
		return
	if World.load_location(World.current_location_id, World.current_spawn_id):
		_feedback("Location reloaded.")

func _on_teleport_square_pressed() -> void:
	_teleport(&"village_square", &"square_east")

func _on_teleport_cafe_pressed() -> void:
	_teleport(&"cafe", &"cafe_entry")

func _on_teleport_church_pressed() -> void:
	_teleport(&"church_exterior", &"church_entry")

func _on_teleport_street_pressed() -> void:
	_teleport(&"main_street", &"street_entry")

func _on_give_wire_pressed() -> void:
	_give_item(&"old_wire")

func _on_give_fuse_pressed() -> void:
	_give_item(&"electrical_fuse")

func _on_give_hook_pressed() -> void:
	_give_item(&"broken_hook")

func _on_set_access_pressed() -> void:
	Story.set_flag(&"church_access_unlocked", true)
	Story.set_flag(&"electrical_problem_fixed", true)
	_refresh_views()
	_feedback("Church access unlocked for debugging.")

func _on_reset_puzzle_pressed() -> void:
	Puzzles.reset(JIMMIS_CONTENT.puzzle_id())
	Story.set_flag(&"electrical_problem_fixed", false)
	Story.set_flag(&"church_access_unlocked", false)
	_refresh_views()
	_feedback("Puzzle state reset.")

func _on_advance_time_pressed() -> void:
	Clock.set_time(Clock.minutes_since_midnight + 15)
	_refresh_views()
	_feedback("Time advanced by fifteen minutes.")

func _teleport(location_id: StringName, spawn_id: StringName) -> void:
	if World.load_location(location_id, spawn_id):
		_feedback("Teleported to %s." % String(location_id))
		_show_hud()
	else:
		_feedback("Teleport failed.")

func _give_item(item_id: StringName) -> void:
	if Inventory.add_item(item_id):
		_refresh_views()
		_feedback("Given %s." % String(item_id))
	else:
		_feedback("Could not give %s." % String(item_id))

func _reset_runtime_state() -> void:
	if not World.current_location_id.is_empty():
		World.unload_current_location()
	GameState.reset()
	Story.restore({})
	Inventory.restore({})
	Puzzles.restore({})
	Quests.restore({})
	Npcs.restore({})
	Clock.set_time(480)
	_active_dialogue_id = &""
	_active_dialogue_node_id = &""
	_active_camera_path = NodePath()
	_pause(false)
	_dialogue_panel.visible = false

func _on_location_loaded(location_id: StringName) -> void:
	if location_id == &"church_interior":
		Quests.complete_objective(JIMMIS_CONTENT.quest_id(), &"enter_church")
	_refresh_views()
	Log.info("location_loaded", "Location entered", {"location_id": location_id, "spawn_id": World.current_spawn_id})

func _on_location_unloaded(location_id: StringName) -> void:
	Log.info("location_unloaded", "Location exited", {"location_id": location_id})
	_refresh_views()

func _on_conversation_started(dialogue_id: StringName, node_id: StringName) -> void:
	_active_dialogue_id = dialogue_id
	_active_dialogue_node_id = node_id
	_dialogue_panel.visible = true
	_refresh_dialogue(Dialogue.current_node())
	Log.info("dialogue_started", "Dialogue started", {"dialogue_id": dialogue_id, "node_id": node_id})

func _on_dialogue_advanced(dialogue_id: StringName, node_id: StringName) -> void:
	_active_dialogue_id = dialogue_id
	_active_dialogue_node_id = node_id
	_refresh_dialogue(Dialogue.current_node())
	Log.info("dialogue_choice", "Dialogue advanced", {"dialogue_id": dialogue_id, "node_id": node_id})

func _on_conversation_ended(dialogue_id: StringName) -> void:
	_active_dialogue_id = &""
	_active_dialogue_node_id = &""
	_dialogue_panel.visible = false
	_feedback("Conversation ended.")
	Log.info("dialogue_ended", "Dialogue ended", {"dialogue_id": dialogue_id})

func _on_interaction_resolved(interaction_id: StringName, verb: StringName, response_text: String) -> void:
	_feedback(response_text if not response_text.is_empty() else "Nothing happens.")
	_refresh_views()
	Log.info("interaction_completed", "Interaction resolved", {"interaction_id": interaction_id, "verb": verb})

func _on_items_combined(first_item_id: StringName, second_item_id: StringName, result_item_id: StringName) -> void:
	if result_item_id == &"repaired_fuse":
		Story.set_flag(&"repair_component_found", true)
		Quests.complete_objective(JIMMIS_CONTENT.quest_id(), &"find_repair_materials")
	if result_item_id == &"retrieval_hook":
		Story.set_flag(&"retrieval_tool_ready", true)
	_refresh_views()
	Log.info("items_combined", "Inventory combination completed", {"first_item_id": first_item_id, "second_item_id": second_item_id, "result_item_id": result_item_id})

func _on_puzzle_completed(puzzle_id: StringName) -> void:
	if puzzle_id == JIMMIS_CONTENT.puzzle_id():
		Quests.complete_objective(JIMMIS_CONTENT.quest_id(), &"repair_nicola_problem")
	_refresh_views()
	Log.info("puzzle_completed", "Puzzle completed", {"puzzle_id": puzzle_id})

func _on_objective_completed(quest_id: StringName, objective_id: StringName) -> void:
	_refresh_views()
	Log.info("objective_completed", "Quest objective completed", {"quest_id": quest_id, "objective_id": objective_id})

func _on_quest_completed(quest_id: StringName) -> void:
	_refresh_views()
	Log.info("quest_completed", "Quest completed", {"quest_id": quest_id})

func _on_relationship_changed(npc_id: StringName, value: int) -> void:
	_refresh_views()
	Log.info("npc_relationship_changed", "Relationship changed", {"npc_id": npc_id, "value": value})

func _on_save_completed(path: String) -> void:
	_refresh_views()
	Log.info("save_created", "Game saved", {"path": path})

func _on_load_completed(path: String) -> void:
	_refresh_views()
	Log.info("save_loaded", "Game loaded", {"path": path})

func _on_camera_changed(camera_path: NodePath) -> void:
	_active_camera_path = camera_path
	_refresh_views()

func _refresh_views() -> void:
	if _location_label != null:
		_location_label.text = "Location: %s  Spawn: %s  Camera: %s  Time: %02d:%02d" % [
			String(World.current_location_id),
			String(World.current_spawn_id),
			String(_active_camera_path),
			Clock.minutes_since_midnight / 60,
			Clock.minutes_since_midnight % 60,
		]
	if _inventory_view != null:
		_inventory_view.text = _build_inventory_text()
	if _quest_view != null:
		_quest_view.text = _build_quest_text()
	if _state_view != null:
		_state_view.text = _build_inspector_text()

func _refresh_dialogue(node: Dictionary) -> void:
	if _dialogue_text == null:
		return
	if node.is_empty():
		_dialogue_text.text = "Conversation ended."
		_clear_dialogue_choices()
		return
	_dialogue_text.text = String(node.get("text", ""))
	_clear_dialogue_choices()
	for choice in node.get("choices", []):
		var choice_button := Button.new()
		choice_button.text = String(choice.get("text", ""))
		var choice_id := StringName(choice.get("id", ""))
		choice_button.pressed.connect(Callable(self, "_on_choice_pressed").bind(choice_id))
		_dialogue_choices.add_child(choice_button)

func _on_choice_pressed(choice_id: StringName) -> void:
	var next_node := Dialogue.choose(choice_id)
	if next_node.is_empty():
		if Dialogue.current_node().is_empty():
			_dialogue_panel.visible = false
			_feedback("Conversation ended.")
		else:
			_refresh_dialogue(Dialogue.current_node())
			_feedback("That choice could not be completed.")
		return
	_refresh_dialogue(next_node)

func _clear_dialogue_choices() -> void:
	for child in _dialogue_choices.get_children():
		child.queue_free()

func _build_inventory_text() -> String:
	var lines: Array[String] = ["INVENTORY"]
	var snapshot := Inventory.snapshot()
	var quantities: Dictionary = snapshot.get("quantities", {})
	if quantities.is_empty():
		lines.append("- empty")
	else:
		for item_id in quantities.keys():
			lines.append("- %s x%d" % [String(item_id), int(quantities[item_id])])
	return "\n".join(lines)

func _build_quest_text() -> String:
	var state: Dictionary = Quests.get_state(JIMMIS_CONTENT.quest_id())
	var lines: Array[String] = ["QUEST"]
	lines.append("- %s" % String(JIMMIS_CONTENT.quest_id()))
	lines.append("- started: %s" % str(bool(state.get("started", false))))
	lines.append("- completed: %s" % str(bool(state.get("completed", false))))
	lines.append("- current objective: %s" % _current_objective_text(state))
	lines.append("- objectives:")
	for objective_id in JIMMIS_CONTENT.quest_objectives():
		lines.append("  * %s = %s" % [String(objective_id), str(bool(state.get("objectives", {}).get(objective_id, false)))])
	lines.append("- optional:")
	for objective_id in JIMMIS_CONTENT.quest_optional_objectives():
		lines.append("  * %s = %s" % [String(objective_id), str(bool(state.get("objectives", {}).get(objective_id, false)))])
	return "\n".join(lines)

func _build_inspector_text() -> String:
	var snapshot := DebugTools.inspect_state()
	var lines: Array[String] = []
	lines.append("LOCATION")
	lines.append(String(snapshot.get("location", "")))
	lines.append("")
	lines.append("PLAYER")
	lines.append(str(_player.global_position) if _player != null else "n/a")
	lines.append("")
	lines.append("FLAGS")
	for flag_id in Story.snapshot().get("flags", {}).keys():
		lines.append("%s = %s" % [String(flag_id), str(bool(Story.has_flag(flag_id)))])
	if Story.snapshot().get("flags", {}).is_empty():
		lines.append("- none")
	lines.append("")
	lines.append("NPCS")
	for npc_id in Npcs.snapshot().get("relationships", {}).keys():
		lines.append("%s = %d" % [String(npc_id), int(Npcs.get_relationship(npc_id))])
	if Npcs.snapshot().get("relationships", {}).is_empty():
		lines.append("- none")
	lines.append("")
	lines.append("RECENT RUNS")
	for summary in Log.get_recent_run_summaries():
		var session: Dictionary = summary.get("session", {})
		lines.append("%s | %s | entries=%d" % [
			String(session.get("label", "")),
			String(session.get("status", "")),
			int(summary.get("entry_count", 0)),
		])
		var last_entry: Dictionary = summary.get("last_entry", {})
		if not last_entry.is_empty():
			lines.append("  %s: %s" % [String(last_entry.get("scope", "")), String(last_entry.get("message", ""))])
	if Log.get_recent_run_summaries().is_empty():
		lines.append("- none")
	return "\n".join(lines)

func _current_objective_text(state: Dictionary) -> String:
	for objective_id in JIMMIS_CONTENT.quest_objectives():
		if not bool(state.get("objectives", {}).get(objective_id, false)):
			return String(objective_id)
	return "complete"

func _feedback(text: String) -> void:
	if _feedback_label != null:
		_feedback_label.text = text

func _make_panel(position: Vector2, size: Vector2, title: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = size
	var title_label := Label.new()
	title_label.text = title
	panel.add_child(title_label)
	return panel

func _panel_vbox(panel: PanelContainer) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.position = Vector2(12.0, 26.0)
	vbox.size = panel.size - Vector2(24.0, 34.0)
	vbox.custom_minimum_size = panel.size - Vector2(24.0, 34.0)
	panel.add_child(vbox)
	return vbox

func _dialogue_vbox_add(parent: VBoxContainer, child: Node) -> void:
	parent.add_child(child)
	child.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _add_label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _add_rich_text(parent: Node, title: String) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = false
	label.fit_content = true
	label.scroll_active = true
	label.text = title
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _add_button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _add_button_row(parent: Node, specs: Array[Dictionary]) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	for spec in specs:
		_add_button(row, String(spec.get("text", "")), spec.get("callable", Callable()))
