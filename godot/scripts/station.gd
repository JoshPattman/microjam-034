class_name Station extends Sprite2D

signal ship_spawned(ship: Player)
signal on_station_exploded()

@export var ship_scene: PackedScene

var current_ship: Node2D

var first: bool = true

func _ready() -> void:
	add_to_group("enemy_targets")
	var life = Life.get_life_script(self)
	if life != null:
		life.on_health_changed.connect(_on_health_changed)
		life.on_die.connect(_on_die)
		life.current_life = 10
	print("Station health started at ", life.current_life, ", ", life.initial_life)
	$TurretShooter/Sprite2D.queue_free()

func _process(delta: float) -> void:
	if first:
		_on_health_changed(Life.get_life_script(self).current_life)
		first = false
	if current_ship == null:
		current_ship = ship_scene.instantiate()
		ship_spawned.emit(current_ship)
		current_ship.position = position
		add_sibling(current_ship)
	$AnimationPlayer.speed_scale = CustomRigidbody2D.get_global_dt_mult()
	
	var dnbs = get_tree().get_nodes_in_group("destroy_near_base")
	for d in dnbs:
		if d is Node2D:
			if d.global_position.distance_squared_to(global_position) < 50*50:
				d.queue_free()

func _on_health_changed(to: float) -> void:
	$HitPlayer.play()
	print("Station health is ", to)
	var game_controller: Game = get_tree().get_first_node_in_group("game_controller")
	game_controller.update_ui_base_health(to)

func _on_die() -> void:
	on_station_exploded.emit()
