extends Node
## Explicit runtime service registry. Core systems register themselves at bootstrap.

var _services: Dictionary = {}

func register_service(service_id: StringName, service: Variant) -> void:
	assert(not service_id.is_empty(), "Service id must not be empty")
	_services[service_id] = service

func get_service(service_id: StringName) -> Variant:
	return _services.get(service_id)

func has_service(service_id: StringName) -> bool:
	return _services.has(service_id)

func clear_services() -> void:
	_services.clear()
