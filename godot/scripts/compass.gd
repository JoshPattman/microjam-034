extends Control

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if player is Node2D:
		var dir = player.global_position.normalized()
		rotation = dir.angle()-PI/2
