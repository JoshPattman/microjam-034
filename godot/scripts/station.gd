class_name Station extends Sprite2D

signal ship_spawned(ship: Player)

@export var ship_scene: PackedScene

var current_ship: Node2D

func _ready() -> void:
	add_to_group("enemy_targets")

func _process(delta: float) -> void:
	if current_ship == null:
		current_ship = ship_scene.instantiate()
		ship_spawned.emit(current_ship)
		current_ship.position = position
		add_sibling(current_ship)
	$AnimationPlayer.speed_scale = CustomRigidbody2D.get_global_dt_mult()
