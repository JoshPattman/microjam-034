extends Node2D

class_name EnemyAvoid

@export var radius: float = 500
@export var weight: float = 1

func _ready() -> void:
	add_to_group("enemy_avoid")
