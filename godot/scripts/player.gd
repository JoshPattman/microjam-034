extends CustomRigidbody2D

class_name Player

signal mined(amount: float)
signal died

@export var max_accel = 500
@export var max_angular_accel = 25
@export var max_linear_breaker_power = 100
@export var max_angular_breaker_power = 50

@export var linear_drag_max_speed = 200
@export var linear_drag: Curve
@export var linear_drag_amount: float = 5
@export var angular_drag_amount: float = 2.5

@export var explosion: PackedScene

@export var collection_radius_sqaure: float = 10000

var is_boost: bool = false:
	set(new):
		if new:
			max_accel = max_accel * 2.0
		else:
			max_accel = max_accel / 2.0

func _ready() -> void:
	add_to_group("player")
	add_to_group("enemy_targets")

func blow_up() -> void:
	var explosion_instance = explosion.instantiate()
	if explosion_instance is Node2D:
		explosion_instance.position = position
		explosion_instance.scale *= 2
	died.emit()
	add_sibling(explosion_instance)
	queue_free()

func _on_rb_collision(point: Vector2, normal: Vector2, other: CustomRigidbody2D) -> void:
	if other is Player:
		return
	other.print_tree()
	blow_up()

func _custom_physics_process(delta: float) -> void:
	var booster = 0.0
	var rotater = 0.0
	var breaker = 0.0
	
	if Input.is_action_pressed("player_forward",true):
		booster += 1.0
	if Input.is_action_pressed("player_back",true):
		booster -= 1.0
	if Input.is_action_pressed("player_left", true):
		rotater -= 1
	if Input.is_action_pressed("player_right", true):
		rotater += 1
	if Input.is_action_pressed("player_break", true):
		breaker = 1
	if Input.is_action_just_pressed("player_boost", true):
		is_boost = true
	if Input.is_action_just_released("player_boost", true):
		is_boost = false
	if Input.is_action_just_pressed("player_collect", true):
		handle_collection()
		
	var linear_drag_val = linear_drag_amount * linear_drag.sample(real_velocity.length() / linear_drag_max_speed)
	var linear_break_val = breaker * max_linear_breaker_power
	var linear_total_slowdown = linear_break_val + linear_drag_val
	
	add_force(get_global_transform().basis_xform(Vector2(0, -booster*max_accel)))
	add_torque(rotater * max_angular_accel)
	
	add_force(-linear_total_slowdown * real_velocity)
	add_torque(-breaker * real_angular_velocity * max_angular_breaker_power - real_angular_velocity * angular_drag_amount)
	
func handle_collection():
	var resources: Array = get_tree().get_nodes_in_group("resources")
	
	print("resource nodes: ", resources)
		
	if resources.is_empty():
		return
	
	var closest_distance: float = INF
	var closest_resource: ResourceAsteroid = null
	for r: ResourceAsteroid in resources:
		var dist = r.transform.origin.distance_squared_to(self.transform.origin)
		if dist < closest_distance:
			closest_distance  = dist
			closest_resource = r
			
	if closest_distance < collection_radius_sqaure:
		mined.emit(closest_resource.mine(1.0))
		
