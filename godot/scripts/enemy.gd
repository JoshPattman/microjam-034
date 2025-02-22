extends CustomRigidbody2D

class_name Enemy

var current_target: Node2D
@export var speed: float = 200
@export var angular_speed: float = 5
@export var drag: float = 0.01

var target_direction: Vector2

@export var k_targeting = 0.5
@export var k_avoiding = 0.5

@export var is_kamikazee: bool = false
@export var kamikazee_range: float = 40
@export var kamikazee_explosion: PackedScene

func _ready() -> void:
	add_to_group("enemies")

func _custom_process(delta: float) -> void:
	if current_target == null:
		current_target = get_next_target()
	
	var d_target: Vector2
	if current_target != null:
		d_target = (current_target.global_position - global_position).normalized()
	
	var avoids = get_tree().get_nodes_in_group("enemy_avoid")
	var d_avoid = Vector2()
	for a in avoids:
		if a is EnemyAvoid:
			var a_delta = a.global_position - global_position
			var a_dist = a_delta.length()
			if a_dist > a.radius:
				continue
			d_avoid -= (a_delta/a_dist) * (1 - (a_dist/a.radius))
	if d_avoid.length() > 1:
		d_avoid = d_avoid.normalized()
	
	target_direction = d_target*k_targeting + d_avoid*k_avoiding
	if target_direction.length() > 1:
		target_direction = target_direction.normalized()
	
	if current_target != null:
		if is_kamikazee:
			if (global_position - current_target.global_position).length() < kamikazee_range:
				blow_up(true)

func blow_up(damage_target:bool = false):
	var exp = kamikazee_explosion.instantiate()
	if exp is Node2D:
		exp.global_position = global_position
		if damage_target:
			exp.scale *= 3
		else:
			exp.scale *= 2
	add_sibling(exp)
	if damage_target:
		if current_target is Player:
			current_target.blow_up()
	queue_free()

func _custom_physics_process(delta: float) -> void:
	if target_direction == Vector2():
		return
	var angle_to_target = target_direction.angle_to(current_forward())
	add_force(target_direction * speed)
	add_force(-real_velocity * real_velocity.length() * drag)
	real_angular_velocity = -angle_to_target * angular_speed

func get_next_target() -> Node2D:
	var targets = get_tree().get_nodes_in_group("enemy_targets")
	var closest_target: Node2D
	var closest_dist: float = 99999999999.0
	for t in targets:
		if t is Node2D:
			var dist = (t.global_position - global_position).length()
			if dist < closest_dist:
				closest_dist = dist
				closest_target = t
	return closest_target
