extends Area2D

@export var allow_suck: bool = true
@export var add_to_asteroid_spawner: bool = false

func _ready() -> void:
	if add_to_asteroid_spawner:
		add_to_group("asteroid_spawner")
	connect("body_entered", on_body_entered)

func on_body_entered(body: Node2D):
	if allow_suck:
		if body is CustomRigidbody2D:
			body.enter_blackhole(global_position)
		else:
			body.queue_free()
