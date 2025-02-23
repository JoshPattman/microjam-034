extends Control

func _ready() -> void:
	var txt = str(Game.last_score)
	while len(txt) < 6:
		txt = "0"+txt
	$Score.text = "Score: "+txt

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("game_restart"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	if Input.is_action_just_pressed("game_quit"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
