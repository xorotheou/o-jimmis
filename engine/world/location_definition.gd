class_name AdventureLocationDefinition
extends Resource
## Content-facing description of a loadable world location.

@export var location_id: StringName
@export_file("*.tscn") var scene_path: String
@export var default_spawn_id: StringName = &"default"

func is_valid_definition() -> bool:
	return not location_id.is_empty() and not scene_path.is_empty() and ResourceLoader.exists(scene_path)
