class_name AdventureInteractionPoint
extends Area3D
## Data anchor for a nearby interaction. Adventure verbs are implemented in Phase 3.

@export var interaction_id: StringName
@export var interaction_distance := 2.0
@export var available_verbs: Array[StringName] = [&"look", &"examine"]

func can_interact_from(actor: Node3D) -> bool:
	return actor.global_position.distance_to(global_position) <= interaction_distance

func request_interaction(verb: StringName) -> bool:
	if not available_verbs.has(verb):
		return false
	GameEvents.interaction_requested.emit(interaction_id, verb)
	return true
