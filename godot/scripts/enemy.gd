extends CustomRigidbody2D

class_name Enemy

var current_target: Node2D
@export var speed: float = 200
@export var angular_speed: float = 5
@export var drag: float = 0.01

func _ready() -> void:
	add_to_group("enemies")

func _custom_process(delta: float) -> void:
	if current_target == null:
		current_target = get_next_target()

func _custom_physics_process(delta: float) -> void:
	if current_target == null:
		return
	var delta_to_target = current_target.position - position
	var angle_to_target = delta_to_target.angle_to(current_forward())
	add_force(delta_to_target.normalized() * speed)
	add_force(-real_velocity * real_velocity.length() * drag)
	real_angular_velocity = -angle_to_target * angular_speed

func get_next_target() -> Node2D:
	return get_tree().get_first_node_in_group("player")
