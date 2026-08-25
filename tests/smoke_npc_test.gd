extends Node
## Headless runtime smoke test for deterministic NPC fallback conversation.

var _failures: Array[String] = []
var _response_seen := ""
var _used_ai_seen := true

func _ready() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var npc := AdventureNpcProfile.new()
	npc.npc_id = &"smoke_npc"
	npc.display_name = "Smoke NPC"
	npc.tier = AdventureNpcProfile.Tier.NAMED
	npc.fallback_lines = ["Stay a while and listen."]

	Npcs.register_profile(npc)
	_assert(Npcs.change_relationship(&"smoke_npc", 17) == 17, "NPC relationship did not update.")
	Npcs.remember(&"smoke_npc", "Met the player.")
	_assert(Npcs.get_relationship(&"smoke_npc") == 17, "NPC relationship did not persist.")

	NpcConversation.response_ready.connect(_on_response_ready)
	var response := NpcConversation.respond(&"smoke_npc", "hello there")
	var second_response := NpcConversation.respond(&"smoke_npc", "hello there")

	_assert(response == "Stay a while and listen.", "NPC fallback response was wrong.")
	_assert(second_response == "Stay a while and listen.", "Cached NPC response was wrong.")
	_assert(_response_seen == "Stay a while and listen.", "NPC response signal was wrong.")
	_assert(not _used_ai_seen, "NPC conversation should not use AI in the fallback path.")
	_assert(Npcs.fallback_line(&"smoke_npc") == "Stay a while and listen.", "Fallback line was not preserved.")

	get_tree().quit(0 if _failures.is_empty() else 1)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failures.append(message)

func _on_response_ready(_npc_id: StringName, response: String, used_ai: bool) -> void:
	_response_seen = response
	_used_ai_seen = used_ai
