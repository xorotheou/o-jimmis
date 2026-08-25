extends Node
## NPC facts, relationships, memory, and schedules stay deterministic and local.

signal relationship_changed(npc_id: StringName, value: int)
signal npc_memory_added(npc_id: StringName, memory: String)
var _profiles: Dictionary = {}
var _relationships: Dictionary = {}
var _memories: Dictionary = {}

func register_profile(profile: AdventureNpcProfile) -> void:
	assert(not profile.npc_id.is_empty(), "NPC profile needs an id")
	_profiles[profile.npc_id] = profile

func change_relationship(npc_id: StringName, delta: int) -> int:
	assert(_profiles.has(npc_id), "NPC must be registered")
	var value := clampi(int(_relationships.get(npc_id, 0)) + delta, -100, 100)
	_relationships[npc_id] = value
	relationship_changed.emit(npc_id, value)
	return value

func get_relationship(npc_id: StringName) -> int:
	return int(_relationships.get(npc_id, 0))

func remember(npc_id: StringName, memory: String) -> void:
	assert(_profiles.has(npc_id), "NPC must be registered")
	if _profiles[npc_id].tier == AdventureNpcProfile.Tier.BACKGROUND: return
	var entries: Array = _memories.get(npc_id, [])
	entries.append(memory)
	_memories[npc_id] = entries.slice(-12)
	npc_memory_added.emit(npc_id, memory)

func fallback_line(npc_id: StringName) -> String:
	var profile: AdventureNpcProfile = _profiles.get(npc_id)
	if profile == null or profile.fallback_lines.is_empty(): return ""
	return profile.fallback_lines[0]

func snapshot() -> Dictionary:
	return {"relationships": _relationships.duplicate(true), "memories": _memories.duplicate(true)}

func restore(snapshot_data: Dictionary) -> void:
	_relationships = snapshot_data.get("relationships", {}).duplicate(true)
	_memories = snapshot_data.get("memories", {}).duplicate(true)
