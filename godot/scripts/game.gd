class_name Game extends Node

@export var asteroid_frequency: float = 1.0

var asteroid_scene = preload("res://game_objects/asteroid.tscn")
var time_since_last_asteroid: float = 0.0

var resource_asteroid_scene = preload("res://game_objects/resource_asteroid.tscn")

func spawn_asteroid():
	var instance = asteroid_scene.instantiate()
	$Asteroids.add_child(instance)

func spawn_resource_asteroid():
	var instance = resource_asteroid_scene.instantiate()
	$Asteroids.add_child(instance)
	
func _process(delta: float) -> void:
	time_since_last_asteroid += delta
	if time_since_last_asteroid > asteroid_frequency:
		spawn_resource_asteroid()
		time_since_last_asteroid = 0.0
