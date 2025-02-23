extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("game_restart"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	if Input.is_action_just_pressed("game_quit"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
