class_name TimeDialater extends Node2D


@export var slow_mult = 0.5
@export var slow_range = 100

@export var pull_force: float = 400.0
@export var pull_range: float = 600.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("time_dialaters")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_multiplier_at(pos: Vector2) -> float:
	var dist = (position-pos).length()
	if dist > slow_range:
		return 1.0
	var t = 1 - (dist / slow_range)
	t = t*t
	return (1-t) * 1.0 + t * slow_mult

func get_acceleration_at(pos: Vector2) -> Vector2:
	var delta = (position-pos)
	var dist = delta.length()
	if dist > pull_range:
		return Vector2()
	return (delta / dist) * (1 - (dist/pull_range)) * pull_force
