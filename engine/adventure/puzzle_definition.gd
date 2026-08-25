class_name AdventurePuzzleDefinition
extends Resource
## Puzzle state and prerequisites are content data; completion actions are deterministic.

@export var puzzle_id: StringName
@export var prerequisites: Array[Dictionary] = []
@export var completion_actions: Array[Dictionary] = []
@export var resettable := false
