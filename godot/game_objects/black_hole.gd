extends Area2D

func _ready() -> void:
	connect("body_entered", on_body_entered)

func on_body_entered(body: Node2D):
	if body is CustomRigidbody2D:
		body.enter_blackhole(global_position)
	else:
		queue_free()
