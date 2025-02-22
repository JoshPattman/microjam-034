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


func _get_random_asteroid_spawn_loc() -> Vector2:
	var all_spawn_locations = get_tree().get_nodes_in_group("asteroid_spawner")
	if len(all_spawn_locations) == 0:
		return Vector2()
	return all_spawn_locations[randi_range(0, len(all_spawn_locations)-1)].global_position

func spawn_asteroid():
	var instance = asteroid_scene.instantiate()
	$Asteroids.add_child(instance)
	instance.global_position = _get_random_asteroid_spawn_loc()

func spawn_enemy():
	if len(get_tree().get_nodes_in_group("enemies")) > max_enemies:
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

func spawn_resource_asteroid():
	var instance = resource_asteroid_scene.instantiate()
	$Asteroids.add_child(instance)
	instance.global_position = _get_random_asteroid_spawn_loc()
	
func _process(delta: float) -> void:
	time_since_last_asteroid += delta * CustomRigidbody2D.get_global_dt_mult()
	if time_since_last_asteroid > asteroid_frequency:
		spawn_resource_asteroid()
		time_since_last_asteroid = 0.0
	
	time_since_last_enemy += delta * CustomRigidbody2D.get_global_dt_mult()
	if time_since_last_enemy > enemy_frequency:
		spawn_enemy()
		time_since_last_enemy = 0
