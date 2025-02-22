class_name Asteroid extends CustomRigidbody2D

@export var speed: float = 1.0

func _ready() -> void:
	real_velocity = Utils.get_random_unit_vector() * speed
