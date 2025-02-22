class_name Asteroid extends CustomRigidbody2D

@export var speed: float = 50.0

func _ready() -> void:
	pass #real_velocity = Utils.get_random_unit_vector() * speed
