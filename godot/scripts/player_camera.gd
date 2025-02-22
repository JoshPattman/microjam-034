extends Camera2D

class_name PlayerCamera

@export var catchup = 3

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player is Player:
		position += (player.position - position) * catchup * delta * player.last_time_scale
