class_name AdventureCameraZone
extends Area3D
## Area selecting a fixed camera when the player enters its authored bounds.

@export var camera_path: NodePath
@onready var camera: Camera3D = get_node(camera_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"adventure_player"):
		camera.make_current()
		GameEvents.camera_changed.emit(camera.get_path())
