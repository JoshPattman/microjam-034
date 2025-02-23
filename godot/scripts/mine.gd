extends CustomRigidbody2D

class_name Mine

@export var explosion_scene: PackedScene

var col: Node2D

var timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy_targets")
	col = $CollisionShape2D
	remove_child(col)

func _on_rb_collision(point: Vector2, normal: Vector2, other: CustomRigidbody2D) -> void:
	if other is Asteroid:
		other.queue_free()
	blow_up()

func _custom_process(delta: float) -> void:
	timer += delta
	if timer > 0.5 && col != null:
		add_child(col)
		col = null

func blow_up() -> void:
	var explosion_instance = explosion_scene.instantiate()
	if explosion_instance is Node2D:
		explosion_instance.position = position
		explosion_instance.scale *= 1
	add_sibling(explosion_instance)
	queue_free()
