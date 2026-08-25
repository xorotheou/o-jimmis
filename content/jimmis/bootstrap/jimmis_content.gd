class_name JimmisContent
extends RefCounted

const LOCATION_SCENES := {
	&"village_square": "res://content/jimmis/locations/village_square.tscn",
	&"cafe": "res://content/jimmis/locations/cafe.tscn",
	&"church_exterior": "res://content/jimmis/locations/church_exterior.tscn",
	&"church_interior": "res://content/jimmis/locations/church_interior.tscn",
	&"main_street": "res://content/jimmis/locations/main_street.tscn",
}

const QUEST_ID := &"vertical_slice_church_problem"
const PUZZLE_ID := &"church_wiring_puzzle"

static func register_all() -> void:
	_register_locations()
	_register_items()
	_register_npcs()
	_register_interactions()
	_register_dialogues()
	_register_puzzles()
	_register_quest()

static func quest_id() -> StringName:
	return QUEST_ID

static func puzzle_id() -> StringName:
	return PUZZLE_ID

static func quest_objectives() -> Array[StringName]:
	return [
		&"investigate_church",
		&"ask_cafe_owner",
		&"speak_with_nicola",
		&"visit_theo",
		&"find_repair_materials",
		&"repair_nicola_problem",
		&"obtain_church_key",
		&"enter_church",
		&"discover_clue",
	]

static func quest_optional_objectives() -> Array[StringName]:
	return [
		&"return_borrowed_tool",
	]

static func _register_locations() -> void:
	for location_id in LOCATION_SCENES.keys():
		var location := AdventureLocationDefinition.new()
		location.location_id = location_id
		location.scene_path = LOCATION_SCENES[location_id]
		match location_id:
			&"village_square":
				location.default_spawn_id = &"square_west"
			&"cafe":
				location.default_spawn_id = &"cafe_entry"
			&"church_exterior":
				location.default_spawn_id = &"church_entry"
			&"church_interior":
				location.default_spawn_id = &"church_interior_entry"
			&"main_street":
				location.default_spawn_id = &"street_entry"
		World.register_location(location)

static func _register_items() -> void:
	_register_item(&"old_wire", "Old Wire", "A spool of weathered wire. It still looks usable.")
	_register_item(&"electrical_fuse", "Electrical Fuse", "A small fuse from Theo's stock, rated for the church panel.")
	_register_item(&"pliers", "Pliers", "Solid pliers with scarred handles. Theo insists they are \"borrowed forever\".")
	_register_item(&"screwdriver", "Screwdriver", "A straight screwdriver with a chipped tip.")
	_register_item(&"cafe_receipt", "Cafe Receipt", "A folded receipt with a penciled note on the back.")
	_register_item(&"broken_hook", "Broken Hook", "A bent metal hook that still has a loop for cord.")
	_register_item(&"rope", "Rope", "A short coil of rope, rough and salt-stiffened.")
	_register_item(&"repaired_fuse", "Repaired Fuse", "A jury-rigged fuse assembly ready for the church panel.")
	_register_item(&"retrieval_hook", "Retrieval Hook", "A makeshift hook and rope rig for reaching a high place.")
	_register_item(&"church_key", "Church Key", "A heavy key for the church interior and storeroom.")
	Inventory.register_definition(_item(&"old_wire", {
		&"electrical_fuse": &"repaired_fuse",
	}))
	Inventory.register_definition(_item(&"electrical_fuse", {
		&"old_wire": &"repaired_fuse",
	}))
	Inventory.register_definition(_item(&"broken_hook", {
		&"rope": &"retrieval_hook",
	}))
	Inventory.register_definition(_item(&"rope", {
		&"broken_hook": &"retrieval_hook",
	}))

static func _register_npcs() -> void:
	_register_npc(&"cafe_owner", AdventureNpcProfile.Tier.MAJOR, "Costa", ["warm", "watchful", "gossipy"], [
		"Everyone asks Costa for gossip before breakfast.",
		"Costa remembers who helped, and who did not.",
	])
	_register_npc(&"nicola", AdventureNpcProfile.Tier.NAMED, "Nicola", ["practical", "guarded", "capable"], [
		"Nicola fixes what other people break.",
		"Nicola notices whether Jimmy kept his word.",
	])
	_register_npc(&"theo", AdventureNpcProfile.Tier.NAMED, "Theo", ["comic", "inventive", "friendly"], [
		"Theo never met a wire he could not narrate.",
		"Theo pretends his tools are priceless even when he hands them over.",
	])
	_register_npc(&"priest", AdventureNpcProfile.Tier.MAJOR, "Priest", ["measured", "observant", "private"], [
		"The priest watches the square before speaking.",
		"The priest remembers which requests were answered.",
	])
	_register_npc(&"villager", AdventureNpcProfile.Tier.BACKGROUND, "Villager", ["busy", "local"], [
		"Nothing major, just the usual village chatter.",
	])

static func _register_interactions() -> void:
	_register_interaction(&"square_fountain", &"look", "The fountain is dry but polished by years of use.", [
		{"type": "set_flag", "id": "square_fountain_seen", "value": true},
	])
	_register_interaction(&"square_noticeboard", &"look", "A noticeboard lists village errands and a church repair note.", [
		{"type": "set_flag", "id": "heard_priest_rumour", "value": true},
	])
	_register_interaction(&"cafe_machine", &"use", "The café machine clicks open. Nicola's fuse problem is finally understandable.", [
		{"type": "set_flag", "id": "nicola_problem_discovered", "value": true},
	])
	_register_interaction(&"cafe_receipt", &"take", "Jimmy pockets the receipt. The back note mentions a faulty relay.", [
		{"type": "add_item", "id": "cafe_receipt"},
	])
	_register_interaction(&"street_wire", &"take", "Jimmy lifts a serviceable coil of old wire from the roadside crate.", [
		{"type": "add_item", "id": "old_wire"},
	])
	_register_interaction(&"street_fuse", &"take", "Jimmy takes the fuse from the workshop shelf.", [
		{"type": "add_item", "id": "electrical_fuse"},
	])
	_register_interaction(&"street_rope", &"take", "Jimmy takes the rope coil. It smells faintly of salt and engine oil.", [
		{"type": "add_item", "id": "rope"},
	])
	_register_interaction(&"broken_hook", &"take", "Jimmy keeps the bent hook. It might be usable with rope.", [
		{"type": "add_item", "id": "broken_hook"},
	])
	_register_interaction(&"church_power_box", &"use", "The repaired fuse seats perfectly. The church panel hums back to life.", [
		{"type": "complete_puzzle", "id": PUZZLE_ID},
	])
	_register_interaction(&"church_storeroom_clue", &"examine", "A ledger scrap mentions the bell mechanism and a hidden note.", [
		{"type": "set_flag", "id": "storeroom_clue_found", "value": true},
		{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"discover_clue"},
	])

static func _register_dialogues() -> void:
	Dialogue.register_definition(_dialogue(&"cafe_owner_dialogue", &"start", [
		_node(&"start", "Costa sets down a cup. \"If you are asking about the church, ask carefully. Nicola has the practical side of the village.\"",
			[
				_choice(&"ask_church", "Ask about the church problem", &"church_problem", [
					{"type": "start_quest", "id": QUEST_ID},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"investigate_church"},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"ask_cafe_owner"},
					{"type": "set_flag", "id": "heard_priest_rumour", "value": true},
					{"type": "remember_npc", "npc_id": "cafe_owner", "memory": "Jimmy asked about the church problem."},
				]),
				_choice(&"ask_nicola", "Ask about Nicola", &"nicola_intro", [
					{"type": "start_quest", "id": QUEST_ID},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"ask_cafe_owner"},
					{"type": "change_relationship", "id": "cafe_owner", "delta": 2},
					{"type": "remember_npc", "npc_id": "cafe_owner", "memory": "Jimmy asked for the Nicola introduction."},
				]),
				_choice(&"ask_priest", "Ask about the priest", &"priest_rumour", [
					{"type": "set_flag", "id": "heard_priest_rumour", "value": true},
					{"type": "remember_npc", "npc_id": "cafe_owner", "memory": "Jimmy asked about the priest."},
				]),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"church_problem", "Costa lowers his voice. \"Nicola will not help for free unless the village problem is understood first.\"",
			[
				_choice(&"about_theo", "Ask who can help", &"theo_intro", [
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"visit_theo"},
				]),
				_choice(&"about_church_key", "Ask about the church key", &"key_hint", [
					{"type": "set_variable", "id": "church_key_hint", "value": "Nicola keeps the key after repairs."},
					{"type": "remember_npc", "npc_id": "cafe_owner", "memory": "Jimmy asked about the church key."},
				]),
				_choice(&"back", "Back to the café counter", &"start"),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"nicola_intro", "Costa taps the side of the cup. \"Nicola works near the church and hates loose wiring.\"",
			[
				_choice(&"ask_problem", "Ask what is wrong", &"theo_intro", [
					{"type": "set_flag", "id": "nicola_problem_discovered", "value": true},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"speak_with_nicola"},
				]),
				_choice(&"ask_help", "Ask if Costa can help", &"help_denied", [
					{"type": "change_relationship", "id": "cafe_owner", "delta": 1},
				]),
				_choice(&"back", "Back to the café counter", &"start"),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"priest_rumour", "Costa says the priest is waiting for someone to restore the storeroom notes after the power problem is solved.",
			[
				_choice(&"follow_up", "Ask where to start", &"church_problem"),
				_choice(&"thank_you", "Thank Costa", &"end", [
					{"type": "change_relationship", "id": "cafe_owner", "delta": 1},
				]),
				_choice(&"back", "Back to the café counter", &"start"),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"key_hint", "Costa shrugs. \"Nicola keeps the key once the repair is done. Ask nicely and bring proof.\"",
			[
				_choice(&"back", "Back to the café counter", &"start"),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"help_denied", "Costa smiles. \"In this village, help usually requires errands first.\"",
			[
				_choice(&"back", "Back to the café counter", &"start"),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"end", "Costa returns to wiping the glass."),
	]))

	Dialogue.register_definition(_dialogue(&"nicola_dialogue", &"start", [
		_node(&"start", "Nicola is crouched beside a dead panel. She nods toward the wiring.", [
				_choice(&"ask_problem", "Ask what broke", &"problem", [
					{"type": "start_quest", "id": QUEST_ID},
					{"type": "set_flag", "id": "nicola_problem_discovered", "value": true},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"speak_with_nicola"},
					{"type": "remember_npc", "npc_id": "nicola", "memory": "Jimmy asked about the dead panel."},
				]),
			_choice(&"ask_help", "Offer to help later", &"need_parts", [
				{"type": "change_relationship", "id": "nicola", "delta": 2},
			]),
			_choice(&"give_fuse", "Hand over the repaired fuse", &"after_repair", [
				{"type": "start_quest", "id": QUEST_ID},
				{"type": "remove_item", "id": "repaired_fuse"},
				{"type": "add_item", "id": "church_key"},
				{"type": "set_flag", "id": "electrical_problem_fixed", "value": true},
				{"type": "set_flag", "id": "church_access_unlocked", "value": true},
				{"type": "set_flag", "id": "church_key_received", "value": true},
				{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"repair_nicola_problem"},
				{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"obtain_church_key"},
				{"type": "change_relationship", "id": "nicola", "delta": 10},
				{"type": "remember_npc", "npc_id": "nicola", "memory": "Jimmy repaired the panel and received the key."},
			], [
				{"type": "flag", "id": "electrical_problem_fixed", "value": true},
				{"type": "has_item", "id": "repaired_fuse", "value": true},
			]),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"problem", "Nicola says the church side relay burns out when the wrong fuse is used.", [
			_choice(&"ask_theo", "Ask who can help", &"theo_reference", [
				{"type": "set_flag", "id": "theo_help_requested", "value": true},
				{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"visit_theo"},
				{"type": "remember_npc", "npc_id": "nicola", "memory": "Jimmy was told to speak with Theo."},
			]),
			_choice(&"back", "Back away from the panel", &"start"),
		]),
		_node(&"need_parts", "Nicola says she needs a proper fuse assembly and the right tools before she trusts anyone near the box.", [
			_choice(&"ask_wire", "Ask about the wire", &"problem"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"theo_reference", "Nicola points down Main Street. \"Theo the electrician keeps the good parts and the bad jokes.\"", [
			_choice(&"ask_key", "Ask about the church key", &"no_key"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"no_key", "Nicola is not giving up the key until the panel is fixed.", [
			_choice(&"back", "Back to the panel", &"start"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"after_repair", "Nicola accepts the repaired fuse and presses the church key into Jimmy's hand.", [
			_choice(&"ask_more", "Ask about the storeroom", &"start", [
				{"type": "set_flag", "id": "church_access_unlocked", "value": true},
			]),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"end", "Nicola returns to the wiring with a focused shrug."),
	]))

	Dialogue.register_definition(_dialogue(&"theo_dialogue", &"start", [
		_node(&"start", "Theo leans on a workbench. \"If it sparks, it is still talking to me.\"",
			[
				_choice(&"borrow_pliers", "Borrow the pliers", &"pliers", [
					{"type": "start_quest", "id": QUEST_ID},
					{"type": "add_item", "id": "pliers"},
					{"type": "set_flag", "id": "theo_help_requested", "value": true},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"visit_theo"},
					{"type": "remember_npc", "npc_id": "theo", "memory": "Jimmy borrowed the pliers."},
				], [
					{"type": "has_item", "id": "pliers", "value": false},
				]),
				_choice(&"borrow_screwdriver", "Borrow the screwdriver", &"screwdriver", [
					{"type": "add_item", "id": "screwdriver"},
					{"type": "remember_npc", "npc_id": "theo", "memory": "Jimmy borrowed the screwdriver."},
				], [
					{"type": "has_item", "id": "screwdriver", "value": false},
				]),
				_choice(&"ask_fuse", "Ask about the fuse", &"fuse_hint", [
					{"type": "set_flag", "id": "theo_help_requested", "value": true},
				]),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"pliers", "Theo grins. \"If you don't bring them back, I will absolutely remember.\"",
			[
				_choice(&"ask_wire", "Ask where to find a wire", &"wire_hint", [
					{"type": "set_variable", "id": "wire_hint", "value": "Look near the workshop crate on Main Street."},
				]),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"screwdriver", "Theo says the screwdriver is on loan. \"Return it and we are both happier.\"",
			[
			_choice(&"offer_return", "Promise to return it", &"tool_return", [
					{"type": "start_quest", "id": QUEST_ID},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"return_borrowed_tool"},
				], [
					{"type": "has_item", "id": "screwdriver", "value": true},
				]),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"fuse_hint", "Theo tells Jimmy the right fuse is on the work shelf on Main Street and the wire is in a roadside crate.",
			[
				_choice(&"thanks", "Thank Theo", &"end", [
					{"type": "change_relationship", "id": "theo", "delta": 2},
				]),
				_choice(&"back", "Back to the bench", &"start"),
			]),
		_node(&"wire_hint", "Theo points toward the road. \"The wire is by the crate. Do not pretend you found it on your own.\"",
			[
				_choice(&"back", "Back to the bench", &"start"),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"tool_return", "Theo is pleased enough to stop joking for a moment.", [
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"end", "Theo goes back to the bench and starts humming."),
	]))

	Dialogue.register_definition(_dialogue(&"priest_dialogue", &"start", [
		_node(&"start", "The priest keeps his voice low. \"The church has a small problem and a larger memory.\"",
			[
				_choice(&"ask_rumour", "Ask about the rumour", &"rumour", [
					{"type": "start_quest", "id": QUEST_ID},
					{"type": "complete_objective", "quest_id": QUEST_ID, "objective_id": &"investigate_church"},
					{"type": "set_flag", "id": "heard_priest_rumour", "value": true},
					{"type": "remember_npc", "npc_id": "priest", "memory": "Jimmy asked about the church rumour."},
				]),
				_choice(&"ask_storeroom", "Ask about the storeroom", &"storeroom", [
					{"type": "set_flag", "id": "priest_warning_heard", "value": true},
				]),
				_choice(&"ask_clue", "Ask about the clue", &"clue", [
					{"type": "change_relationship", "id": "priest", "delta": 1},
				]),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"rumour", "He says Nicola will not hand over the key until the repair is genuinely fixed.", [
			_choice(&"ask_nicola", "Ask where Nicola is", &"start"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"storeroom", "The priest says the storeroom holds an old ledger, a spare candle, and very little patience.", [
			_choice(&"ask_help", "Ask how to help", &"clue"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"clue", "He nods once. \"When you reach the storeroom, examine the ledger shelf and do not move anything else.\"",
			[
				_choice(&"thank_you", "Thank him", &"end", [
					{"type": "set_flag", "id": "priest_helped", "value": true},
				]),
				_choice(&"leave", "Leave", &"end"),
			]),
		_node(&"end", "The priest returns to his quiet watch."),
	]))

	Dialogue.register_definition(_dialogue(&"villager_dialogue", &"start", [
		_node(&"start", "A villager glances up from a basket of vegetables.", [
			_choice(&"ask_square", "Ask about the square", &"square", [
				{"type": "remember_npc", "npc_id": "villager", "memory": "Jimmy asked about the square."},
			]),
			_choice(&"ask_cafe", "Ask about the café", &"cafe", [
				{"type": "set_flag", "id": "villager_cafe_rumour", "value": true},
			]),
			_choice(&"ask_church", "Ask about the church", &"church", [
				{"type": "set_flag", "id": "heard_priest_rumour", "value": true},
			]),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"square", "The villager says the fountain used to be a meeting point before the repair problem.", [
			_choice(&"back", "Back to the villager", &"start"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"cafe", "The café is the fastest way to hear news, unless Costa decides otherwise.", [
			_choice(&"back", "Back to the villager", &"start"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"church", "The church has been quieter since the power flicker started.", [
			_choice(&"back", "Back to the villager", &"start"),
			_choice(&"leave", "Leave", &"end"),
		]),
		_node(&"end", "The villager returns to the basket."),
	]))

static func _register_puzzles() -> void:
	var puzzle := AdventurePuzzleDefinition.new()
	puzzle.puzzle_id = PUZZLE_ID
	puzzle.prerequisites = [
		{"type": "flag", "id": "theo_help_requested", "value": true},
		{"type": "has_item", "id": "repaired_fuse", "value": true},
	]
	puzzle.completion_actions = [
		{"type": "set_flag", "id": "electrical_problem_fixed", "value": true},
		{"type": "set_flag", "id": "church_access_unlocked", "value": true},
		{"type": "set_variable", "id": "church_power_state", "value": "restored"},
	]
	Puzzles.register_definition(puzzle)

static func _register_quest() -> void:
	var quest := AdventureQuestDefinition.new()
	quest.quest_id = QUEST_ID
	quest.title = "Vertical Slice: Church Problem"
	quest.objective_ids = [
		&"investigate_church",
		&"ask_cafe_owner",
		&"speak_with_nicola",
		&"visit_theo",
		&"find_repair_materials",
		&"repair_nicola_problem",
		&"obtain_church_key",
		&"enter_church",
		&"discover_clue",
	]
	quest.optional_objective_ids = quest_optional_objectives()
	quest.completion_actions = [
		{"type": "set_flag", "id": "vertical_slice_complete", "value": true},
		{"type": "set_variable", "id": "vertical_slice_summary", "value": "church_problem_solved"},
	]
	Quests.register_definition(quest)

static func _register_item(item_id: StringName, display_name: String, inspection_text: String) -> void:
	var item := AdventureItemDefinition.new()
	item.item_id = item_id
	item.display_name = display_name
	item.inspection_text = inspection_text
	Inventory.register_definition(item)

static func _item(item_id: StringName, combinations: Dictionary) -> AdventureItemDefinition:
	var item := AdventureItemDefinition.new()
	item.item_id = item_id
	item.display_name = String(item_id).capitalize().replace("_", " ")
	item.combination_results = combinations
	return item

static func _register_npc(npc_id: StringName, tier: AdventureNpcProfile.Tier, display_name: String, personality_tags: Array[StringName], fallback_lines: Array[String]) -> void:
	var profile := AdventureNpcProfile.new()
	profile.npc_id = npc_id
	profile.tier = tier
	profile.display_name = display_name
	profile.personality_tags = personality_tags
	profile.fallback_lines = fallback_lines
	Npcs.register_profile(profile)

static func _register_interaction(interaction_id: StringName, verb: StringName, response_text: String, consequences: Array[Dictionary]) -> void:
	var interaction := AdventureInteractionDefinition.new()
	interaction.interaction_id = interaction_id
	interaction.verb = verb
	interaction.response_text = response_text
	interaction.consequences = consequences
	Interaction.register_definition(interaction)

static func _dialogue(dialogue_id: StringName, start_node_id: StringName, nodes: Array[Dictionary]) -> AdventureDialogueDefinition:
	var dialogue := AdventureDialogueDefinition.new()
	dialogue.dialogue_id = dialogue_id
	dialogue.start_node_id = start_node_id
	dialogue.nodes = nodes
	return dialogue

static func _node(node_id: StringName, text: String, choices: Array[Dictionary] = [], conditions: Array[Dictionary] = []) -> Dictionary:
	return {"id": node_id, "text": text, "choices": choices, "conditions": conditions}

static func _choice(choice_id: StringName, text: String, next_node_id: StringName, consequences: Array[Dictionary] = [], conditions: Array[Dictionary] = []) -> Dictionary:
	return {"id": choice_id, "text": text, "next_node_id": next_node_id, "consequences": consequences, "conditions": conditions}
