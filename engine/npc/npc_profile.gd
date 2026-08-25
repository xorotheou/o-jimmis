class_name AdventureNpcProfile
extends Resource
## NPC content profile. Tier controls the amount of retained state and AI context.

enum Tier { MAJOR, NAMED, BACKGROUND }
@export var npc_id: StringName
@export var tier: Tier = Tier.BACKGROUND
@export var display_name := ""
@export var personality_tags: Array[StringName] = []
@export var knowledge: Array[StringName] = []
@export var fallback_lines: Array[String] = []
@export var schedule: Array[Dictionary] = []
@export var ai_enabled := false
