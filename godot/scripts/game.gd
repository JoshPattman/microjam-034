class_name Game extends Node

@export var asteroid_frequency: float = 1.0

var asteroid_scene = preload("res://game_objects/asteroid.tscn")
var time_since_last_asteroid: float = 0.0

var resource_asteroid_scene = preload("res://game_objects/resource_asteroid.tscn")

@export var enemy_spawn_groups: Array[SpawnGroup]
@export var enemy_frequency: float = 1.0
@export var max_enemies = 10
@export var enemy_spawn_radius: float = 50
var time_since_last_enemy: float = 0.0

var player_resources: float = 0.0:
	set(new):
		$PlayerCamera/UI/Resources/Label.text = str(new)
		player_resources = new

func _ready() -> void:
	$Station.ship_spawned.connect(
		func(ship):
			ship.mined.connect(func(amount): player_resources += amount)
			ship.died.connect(func(): player_resources = 0.0)
	)
	_spawn_initial_asteroids()
	
func _process(delta: float) -> void:
	time_since_last_asteroid += delta * CustomRigidbody2D.get_global_dt_mult()
	if time_since_last_asteroid > asteroid_frequency:
		_spawn_meteroite()
		time_since_last_asteroid = 0.0
	
	time_since_last_enemy += delta * CustomRigidbody2D.get_global_dt_mult()
	if time_since_last_enemy > enemy_frequency:
		_spawn_enemy()
		time_since_last_enemy = 0

func _spawn_enemy():
	if len(get_tree().get_nodes_in_group("enemies")) >= max_enemies:
		return
	var group = enemy_spawn_groups[randi_range(0, len(enemy_spawn_groups)-1)]
	var loc = _get_random_asteroid_spawn_loc()
	var angle: float = 0.0
	for elem: PackedScene in group.items:
		var ins = elem.instantiate()
		add_child(ins)
		if ins is Node2D:
			ins.global_position = loc + Vector2(1, 0).rotated(angle)
		angle += PI * 2 / len(group.items)
		print("Spawned ", ins.name)

func _spawn_initial_asteroids() -> void:
	var cell_size = 40
	for x in range(-2000, 2000, cell_size):
		for y in range(-1000, 1000, cell_size):
			if randf() > 0.99:
				_spawn_asteroid(Vector2(x, y), randf()>0.8, Vector2())

func _spawn_meteroite() -> void:
	_spawn_asteroid(_get_random_asteroid_spawn_loc(), randf()>0.8, Utils.get_random_unit_vector() * 30)

func _spawn_asteroid(at: Vector2, has_res: bool, velocity: Vector2) -> Asteroid:
	var instance: Asteroid
	if !has_res:
		instance = asteroid_scene.instantiate()
	else:
		instance = resource_asteroid_scene.instantiate()
	$Asteroids.add_child(instance)
	instance.global_position = at
	instance.real_velocity = velocity
	return instance

func _get_random_asteroid_spawn_loc() -> Vector2:
	var all_spawn_locations = get_tree().get_nodes_in_group("asteroid_spawner")
	if len(all_spawn_locations) == 0:
		return Vector2()
	return all_spawn_locations[randi_range(0, len(all_spawn_locations)-1)].global_position
