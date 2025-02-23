class_name Asteroid extends CustomRigidbody2D

func _ready() -> void:
	pass

func _on_rb_collision(point: Vector2, normal: Vector2, other: CustomRigidbody2D) -> void:
	if other is Asteroid:
		real_velocity = real_velocity.bounce(normal)
