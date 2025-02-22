extends CustomRigidbody2D

class_name Enemy

var current_target: Node2D
@export var speed: float = 200
@export var angular_speed: float = 5
@export var drag: float = 0.01

var target_direction: Vector2

@export var k_targeting = 0.5
@export var k_avoiding = 0.5

func _ready() -> void:
	add_to_group("enemies")

func _custom_process(delta: float) -> void:
	if current_target == null:
		current_target = get_next_target()
	
	var d_target = (current_target.global_position - global_position).normalized()
	
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

func _custom_physics_process(delta: float) -> void:
	if target_direction == Vector2():
		return
	var angle_to_target = target_direction.angle_to(current_forward())
	add_force(target_direction * speed)
	add_force(-real_velocity * real_velocity.length() * drag)
	real_angular_velocity = -angle_to_target * angular_speed

func get_next_target() -> Node2D:
	return get_tree().get_first_node_in_group("player")
