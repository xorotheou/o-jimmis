class_name AdventureInteractionDefinition
extends Resource
## Data-driven target response keyed by a verb; actions remain deterministic.

@export var interaction_id: StringName
@export var verb: StringName
@export_multiline var response_text := ""
@export var conditions: Array[Dictionary] = []
@export var consequences: Array[Dictionary] = []
