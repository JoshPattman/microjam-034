class_name Utils extends Node

static func get_random_unit_vector() -> Vector2:
	var angle = randf_range(0, TAU)
	return Vector2(cos(angle), sin(angle))
