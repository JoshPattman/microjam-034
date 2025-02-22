class_name Game extends Node

@export var asteroid_frequency: float = 1.0

var asteroid_scene = preload("res://game_objects/asteroid.tscn")
var time_since_last_asteroid: float = 0.0

func spawn_asteroid():
	var asteroid_instance = asteroid_scene.instantiate()
	$Asteroids.add_child(asteroid_instance)
	
func _process(delta: float) -> void:
	time_since_last_asteroid += delta
	if time_since_last_asteroid > asteroid_frequency:
		spawn_asteroid()
		time_since_last_asteroid = 0.0
