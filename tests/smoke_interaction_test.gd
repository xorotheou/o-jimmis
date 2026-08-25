extends Node
## Headless runtime smoke test for deterministic interaction resolution.

var _failures: Array[String] = []
var _observed_interaction_id: StringName = &""
var _observed_verb: StringName = &""
var _observed_text := ""

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var interaction := AdventureInteractionDefinition.new()
	interaction.interaction_id = &"smoke_door"
	interaction.verb = &"open"
	interaction.response_text = "The door opens."
	interaction.consequences = [
		{"type": "set_flag", "id": "smoke_interaction_opened", "value": true},
		{"type": "set_variable", "id": "smoke_interaction_text", "value": "opened"},
	]

	Interaction.interaction_resolved.connect(_on_interaction_resolved)

	Interaction.register_definition(interaction)
	var response := Interaction.resolve(&"smoke_door", &"open")

	_assert(response == "The door opens.", "Interaction did not return the expected response.")
	_assert(_observed_interaction_id == &"smoke_door", "Interaction signal used the wrong id.")
	_assert(_observed_verb == &"open", "Interaction signal used the wrong verb.")
	_assert(_observed_text == "The door opens.", "Interaction signal used the wrong response text.")
	_assert(Story.has_flag(&"smoke_interaction_opened"), "Interaction consequence did not set the flag.")
	_assert(String(Story.get_variable(&"smoke_interaction_text", "")) == "opened", "Interaction consequence did not set the variable.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

func _on_interaction_resolved(interaction_id: StringName, verb: StringName, response_text: String) -> void:
	_observed_interaction_id = interaction_id
	_observed_verb = verb
	_observed_text = response_text
