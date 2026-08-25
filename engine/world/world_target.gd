class_name AdventureWorldTarget
extends Area3D
## Generic clickable world target for NPCs, props, and exits.

enum TargetKind { INTERACTION, DIALOGUE, EXIT }

@export var target_kind: TargetKind = TargetKind.INTERACTION
@export var target_id: StringName
@export var interaction_verb: StringName = &"use"
@export var dialogue_id: StringName
@export var location_id: StringName
@export var spawn_id: StringName = &""
@export var activation_distance := 2.0
@export var conditions: Array = []

func can_activate_from(actor: Node3D) -> bool:
	return actor != null and actor.global_position.distance_to(global_position) <= activation_distance and is_available()

func is_available() -> bool:
	return Interaction._conditions_met(conditions)

func activation_point() -> Vector3:
	return global_position

func activate() -> void:
	match target_kind:
		TargetKind.INTERACTION:
			GameEvents.interaction_requested.emit(target_id, interaction_verb)
		TargetKind.DIALOGUE:
			Dialogue.start(dialogue_id)
		TargetKind.EXIT:
			GameEvents.location_requested.emit(location_id, spawn_id)
