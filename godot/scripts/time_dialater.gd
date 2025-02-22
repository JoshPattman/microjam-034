class_name TimeDialater extends Node2D


@export var multiplier = 0.5
@export var range = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("time_dialaters")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_multiplier_at(pos: Vector2) -> float:
	var dist = (position-pos).length()
	if dist <= range:
		return multiplier
	else:
		return 1.0
