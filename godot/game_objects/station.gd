extends Sprite2D

@export var ship_scene: PackedScene

var current_ship: Node2D

func _ready() -> void:
	add_to_group("enemy_targets")

func _process(delta: float) -> void:
	if current_ship == null:
		current_ship = ship_scene.instantiate()
		current_ship.position = position
		add_sibling(current_ship)
