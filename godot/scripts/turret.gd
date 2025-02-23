extends Node2D

class_name Turret

@export_category("Turret")
@export var range: float = 200
@export var shot_delay: float = 1.0:
	set(new):
		if $AnimationPlayer != null:
			$AnimationPlayer.speed_scale = 1.0 / shot_delay
@export var is_single_shot: bool = true
@export var is_pusher: bool = false
@export var push_prefab: PackedScene
@export var push_for: float = 3.0

@export_category("Enemies")
@export var add_to_targets: bool = true

var time_since_last_shot: float = 0.0
var pushing_time_left: float = 0.0
var current_push_prefab: Node2D

func _ready() -> void:
	if add_to_targets:
		add_to_group("enemy_targets")

func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Enemy
	var closest_dist_squared: float = 9999999.9
	for e in enemies:
		if e is Enemy:
			var dist = e.global_position.distance_squared_to(global_position)
			if dist < closest_dist_squared:
				closest_dist_squared = dist
				closest_enemy = e
	
	if closest_dist_squared < range*range:
		if time_since_last_shot > shot_delay:
			time_since_last_shot = 0.0
			if is_single_shot:
				closest_enemy.blow_up()
				$AnimationPlayer.play("charge")
				_handle_shot(closest_enemy.global_position)
			elif is_pusher:
				pushing_time_left = push_for
				var pu = push_prefab.instantiate()
				if pu is Node2D:
					pu.global_position = global_position
					if current_push_prefab != null:
						current_push_prefab.queue_free()
					current_push_prefab = pu
					add_child(current_push_prefab)
			else:
				print("useless turret")
	
	if current_push_prefab != null && pushing_time_left <= 0:
		current_push_prefab.queue_free()
	
	var rdelta = delta * CustomRigidbody2D.get_global_dt_mult()
	time_since_last_shot += rdelta
	pushing_time_left -= rdelta

	
func _handle_shot(pos: Vector2):
	$Shot.visible = true
	$Shot.modulate.a = 1.0
	$Shot.clear_points()
	$Shot.add_point($Shot.to_local(self.global_position))
	$Shot.add_point($Shot.to_local(pos))
	var tween = get_tree().create_tween()
	tween.tween_property($Shot, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): $Shot.visible = false)
