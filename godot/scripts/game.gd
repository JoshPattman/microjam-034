class_name Game extends Node

@export var asteroid_frequency: float = 1.0

var asteroid_scene = preload("res://game_objects/asteroid.tscn")
var time_since_last_asteroid: float = 0.0

var resource_asteroid_scene = preload("res://game_objects/resource_asteroid.tscn")

@export var score_per_wave: int = 250

@export_category("Turrets")
@export var shooter_prefab: PackedScene
@export var bouncer_prefab: PackedScene
@export var mine_prefab: PackedScene

@export var shooter_turret_cost: float = 5.0
@export var bouncer_turret_cost: float = 3.0
@export var mine_turret_cost: float = 1.0

@export_category("Spawning")
@export var wave_count_m: float = 2
@export var wave_count_c: float = 2
@export var wave_delay: float = 30.0
@export var enemy_spawn_groups: Array[SpawnGroup]

var wave_counter: int = 0
var wave_timer: float = 0.0

static var last_score: int = 0

var score: int = 0:
	set(new):
		var txt = str(new)
		while len(txt) < 6:
			txt = "0"+txt
		$PlayerCamera/UI/Score.text = txt
		score = new

var player_resources: float = 0.0:
	set(new):
		$PlayerCamera/UI/Stats/Resources/Label.text = str(new)
		player_resources = new

var player_boosts: float = 0.0:
	set(new):
		$PlayerCamera/UI/Stats/Boost/Label.text = str(new)
		player_boosts = new

func update_ui_health(health: float):
	$PlayerCamera/UI/Stats/Sheilds/Label.text = str(health-1)

func update_ui_base_health(health: float):
	$PlayerCamera/UI/Stats/Base/Label.text = str(health)

func _ready() -> void:
	$Station.ship_spawned.connect(
		func(ship):
			ship.mined.connect(func(amount): player_resources += amount)
			ship.died.connect(func(): player_resources = 0.0)
	)
	_spawn_initial_asteroids()
	add_to_group("game_controller")
	$Station.on_station_exploded.connect(_on_die)
	score = 0

func _on_die() -> void:
	last_score = score
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _process(delta: float) -> void:
	time_since_last_asteroid += delta * CustomRigidbody2D.get_global_dt_mult()
	if time_since_last_asteroid > asteroid_frequency:
		_spawn_meteroite()
		time_since_last_asteroid = 0.0
	
	if wave_timer > wave_delay:
		var count: int = round(wave_count_m * float(wave_counter) + wave_count_c)
		print("Spawning ", count, " enemy groups")
		score += score_per_wave
		for i in range(count):
			_spawn_enemy_group(randf()>0.85)
		wave_timer = 0
		wave_counter += 1
	wave_timer += delta * CustomRigidbody2D.get_global_dt_mult()
	
	
	$PlayerCamera/UI/TopBar/Slider.position.x = remap(
		log(CustomRigidbody2D.get_global_dt_mult()) / log(10),
		1,
		-1,
		$PlayerCamera/UI/TopBar/BlackholeAnchor.position.x,
		$PlayerCamera/UI/TopBar/WhiteholeAnchor.position.x
	) - $PlayerCamera/UI/TopBar/Slider.size.x / 2
	
	
	if !is_equal_approx(1.0, CustomRigidbody2D.get_global_dt_mult()):
		$PlayerCamera/UI/TimeDilation.visible = true
		$PlayerCamera/UI/TimeDilation/Amount.text = "%.3f" % CustomRigidbody2D.get_global_dt_mult()
	else:
		$PlayerCamera/UI/TimeDilation.visible = false
	
	_handle_placing()


func _spawn_enemy_group(at_player: bool):
	var relev_spawn_groups: Array[SpawnGroup] = []
	for s in enemy_spawn_groups:
		if s.min_wave <= wave_counter:
			relev_spawn_groups.append(s)
	var group = relev_spawn_groups[randi_range(0, len(relev_spawn_groups)-1)]
	var loc = _get_random_enemy_spawn_loc(at_player)
	var angle: float = 0.0
	for elem: PackedScene in group.items:
		var ins = elem.instantiate()
		if ins is Node2D:
			ins.global_position = loc + Vector2(100, 0).rotated(angle)
		angle += PI * 2 / len(group.items)
		add_child(ins)

func _spawn_initial_asteroids() -> void:
	for i in range(8):
		var cx = randf_range(-2500, 2500)
		var cy = randf_range(-2500, 2500)
		for j in range(15):
			var ox = randf_range(-250, 250)
			var oy = randf_range(-250, 250)
			_spawn_asteroid(Vector2(cx+ox, cy+oy), randf()>0.8, Vector2(), 0.6+randf())

func _spawn_meteroite() -> void:
	_spawn_asteroid(_get_random_asteroid_spawn_loc(), randf()>0.8, Utils.get_random_unit_vector() * 100, 0.6+randf())

func _spawn_asteroid(at: Vector2, has_res: bool, velocity: Vector2, scale: float) -> Asteroid:
	var instance: Asteroid
	if !has_res:
		instance = asteroid_scene.instantiate()
	else:
		instance = resource_asteroid_scene.instantiate()
	instance.global_position = at
	instance.real_velocity = velocity
	instance.scale *= scale
	if instance is ResourceAsteroid:
		instance.reset_resources()
	$Asteroids.add_child(instance)
	return instance

func _get_random_asteroid_spawn_loc() -> Vector2:
	var all_spawn_locations = get_tree().get_nodes_in_group("asteroid_spawner")
	if len(all_spawn_locations) == 0:
		return Vector2()
	return all_spawn_locations[randi_range(0, len(all_spawn_locations)-1)].global_position


func _get_random_enemy_spawn_loc(at_player: bool) -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	var player_pos = Vector2()
	if player != null and player is Node2D:
		player_pos = player.global_position
	
	if at_player:
		# Spawn around the player
		return player_pos + Vector2(sqrt(randf_range(500*500, 1000*1000)), 0).rotated(randf_range(0, PI))
	else:
		# Spawn around the base
		var loc: Vector2 = player_pos
		while loc.distance_to(player_pos) < 800:
			loc = Vector2(sqrt(randf_range(0, 1000*1000)), 0).rotated(randf_range(0, PI))
		return loc

func _handle_placing() -> void:
	if Input.is_action_just_pressed("player_place_shooter") && player_resources >= shooter_turret_cost:
		_place(shooter_prefab)
		player_resources -= shooter_turret_cost
		$PlaceTowerPlayer.play()
	if Input.is_action_just_pressed("player_place_bouncer") && player_resources >= bouncer_turret_cost:
		_place(bouncer_prefab)
		player_resources -= bouncer_turret_cost
		$PlaceTowerPlayer.play()
	if Input.is_action_just_pressed("player_place_mine") && player_resources >= mine_turret_cost:
		_place(mine_prefab)
		player_resources -= mine_turret_cost
		$PlaceTowerPlayer.play()

func _place(tower: PackedScene) -> Node2D:
	var player: Player = get_tree().get_first_node_in_group("player")
	var ins: Node2D = tower.instantiate()
	ins.global_position = player.global_position
	add_child(ins)
	return null
