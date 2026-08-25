class_name AdventureQuestDefinition
extends Resource
## Authored quest with ordered objectives and deterministic completion rewards.

@export var quest_id: StringName
@export var title := ""
@export var objective_ids: Array[StringName] = []
@export var completion_actions: Array[Dictionary] = []
