class_name Asteroid extends CustomRigidbody2D

@export var max_velocity: float = 100

func _ready() -> void:
	add_to_group("destroy_near_base")

func _on_rb_collision(point: Vector2, normal: Vector2, other: CustomRigidbody2D) -> void:
	if other is Asteroid:
		real_velocity = real_velocity.bounce(normal)

	var other_life = Life.get_life_script(other)
	if other_life != null:
		other_life.damage(1)

func _custom_physics_process(delta: float) -> void:
	if real_velocity.length() > max_velocity:
		real_velocity = real_velocity.normalized() * max_velocity
