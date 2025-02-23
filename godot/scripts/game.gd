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

@export var shooter_prefab: PackedScene
@export var bouncer_prefab: PackedScene

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
	
	if !is_equal_approx(1.0, CustomRigidbody2D.get_global_dt_mult()):
		$PlayerCamera/UI/TimeDilation.visible = true
		$PlayerCamera/UI/TimeDilation/Amount.text = "%.3f" % CustomRigidbody2D.get_global_dt_mult()
	else:
		$PlayerCamera/UI/TimeDilation.visible = false
	
	_handle_placing()


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

func _spawn_initial_asteroids() -> void:
	for i in range(8):
		var cx = randf_range(-2500, 2500)
		var cy = randf_range(-2500, 2500)
		for j in range(15):
			var ox = randf_range(-250, 250)
			var oy = randf_range(-250, 250)
			_spawn_asteroid(Vector2(cx+ox, cy+oy), randf()>0.8, Vector2())

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

func _handle_placing() -> void:
	if Input.is_action_just_pressed("player_place_shooter") && player_resources >= 5:
		_place(shooter_prefab)
		player_resources -= 5
	if Input.is_action_just_pressed("player_place_bouncer") && player_resources >= 3:
		_place(bouncer_prefab)
		player_resources -= 3

func _place(tower: PackedScene) -> Node2D:
	var player: Player = get_tree().get_first_node_in_group("player")
	var ins: Node2D = tower.instantiate()
	ins.global_position = player.global_position
	add_child(ins)
	return null
