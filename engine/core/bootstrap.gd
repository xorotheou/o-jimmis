extends Node
## Starts engine services. Game-specific entry scenes are requested via GameEvents.

func _ready() -> void:
	Services.register_service("events", GameEvents)
	Services.register_service("state", GameState)
	Services.register_service("config", EngineConfig)
	Services.register_service("logger", Log)
	Services.register_service("world", World)
	Services.register_service("story", Story)
	Services.register_service("inventory", Inventory)
	Services.register_service("interaction", Interaction)
	Services.register_service("dialogue", Dialogue)
	Services.register_service("puzzles", Puzzles)
	Services.register_service("quests", Quests)
	Services.register_service("npcs", Npcs)
	Services.register_service("save", Save)
	Log.info("bootstrap", "Adventure Engine foundation initialized")
	GameEvents.location_requested.connect(World.load_location)
	GameEvents.interaction_requested.connect(Interaction.resolve)
	GameEvents.engine_ready.emit()
