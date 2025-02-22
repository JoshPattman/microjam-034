extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(finish)
	$AnimatedSprite2D.play()
	
	$AudioStreamPlayer.finished.connect(finish)

var num_finish: int = 0

func finish() -> void:
	num_finish += 1
	if num_finish == 2:
		queue_free()
