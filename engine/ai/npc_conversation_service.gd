extends Node
## Non-authoritative conversation facade. It always has a deterministic fallback.

signal response_ready(npc_id: StringName, response: String, used_ai: bool)
var _cache: Dictionary = {}

func respond(npc_id: StringName, player_text: String) -> String:
	var cache_key := "%s:%s" % [npc_id, player_text.to_lower()]
	if _cache.has(cache_key):
		return _emit(npc_id, _cache[cache_key], false)
	# Network/model adapters belong behind this method; no gameplay state is mutated here.
	var response := Npcs.fallback_line(npc_id)
	_cache[cache_key] = response
	return _emit(npc_id, response, false)

func _emit(npc_id: StringName, response: String, used_ai: bool) -> String:
	response_ready.emit(npc_id, response, used_ai)
	return response
