extends Node2D

class_name SpecialResourceSource

@export var boost: float = 0.0
@export var health: float = 0.0

func _ready() -> void:
	add_to_group("resources")
