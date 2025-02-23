extends Control

@export var game_scene: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("game_restart"):
		get_tree().change_scene_to_packed(game_scene)
	if Input.is_action_just_pressed("game_quit"):
		get_tree().quit()
