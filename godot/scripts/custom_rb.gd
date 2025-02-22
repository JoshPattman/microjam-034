extends CharacterBody2D

class_name CustomRigidbody2D

@export var maintain_constant_time: bool = false

var real_velocity: Vector2 = Vector2()
var real_angular_velocity: float = 0.0

var _total_real_force: Vector2 = Vector2()
var _total_real_torque: float = 0.0

var last_time_scale = 1.0

var local_time_mult: float = 1.0
static var player_time_mult: float = 1.0

var local_gravity_accel: Vector2 = Vector2()

# This function should use gme time velocity and is passed in game time delta
func _move_and_slide(delta: float) -> void:
	move_and_slide()
	
# Override this to do physics
func _custom_physics_process(delta: float) -> void:
	pass

func _custom_process(delta: float) -> void:
	pass

func _custom_post_physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	var tm = calculate_time_multiplier()
	if maintain_constant_time:
		local_time_mult = 1.0
		player_time_mult = tm
	else:
		local_time_mult = tm
	
	local_gravity_accel = calculate_gravity_accel()
	
	_custom_process(delta)

func _physics_process(delta: float) -> void:
	var tm = local_time_mult
	if !maintain_constant_time:
		tm /= player_time_mult
	var real_delta = delta * tm
	_custom_physics_process(real_delta)
	
	add_force(local_gravity_accel)
	
	var real_acceleration = _total_real_force
	real_velocity += real_acceleration * real_delta
	
	var real_angular_acceleration = _total_real_torque
	real_angular_velocity += real_angular_acceleration * real_delta
	
	rotation += real_angular_velocity * real_delta
	velocity = real_velocity * tm
	_move_and_slide(delta)
	
	_custom_post_physics_process(real_delta)
	
	_total_real_force = Vector2()
	_total_real_torque = 0
	last_time_scale = tm


func calculate_time_multiplier() -> float:
	var tds = get_tree().get_nodes_in_group("time_dialaters")
	var total_muliplier = 1.0
	for node in tds:
		if node is TimeDialater:
			total_muliplier *= node.get_multiplier_at(position)
	return total_muliplier

func calculate_gravity_accel() -> Vector2:
	var tds = get_tree().get_nodes_in_group("time_dialaters")
	var total_accel = Vector2()
	for node in tds:
		if node is TimeDialater:
			total_accel += node.get_acceleration_at(position)
	return total_accel

func add_force(force: Vector2) -> void:
	_total_real_force += force

func add_torque(torque: float) -> void:
	_total_real_torque += torque

func current_forward() -> Vector2:
	return get_global_transform().basis_xform(Vector2(0, -1))
