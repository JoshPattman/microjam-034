extends CustomRigidbody2D

class_name Player

signal mined(amount: float)
signal died

@export var max_accel = 500
@export var max_angular_accel = 25
@export var max_linear_breaker_power = 100
@export var max_angular_breaker_power = 50

@export var linear_drag_max_speed = 200
@export var linear_drag: Curve
@export var linear_drag_amount: float = 5
@export var angular_drag_amount: float = 2.5

@export var explosion: PackedScene

@export var collection_radius_sqaure: float = 40000
@export var mine_rate: float = 0.5
@export var mine_amount: float = 0.5

var connected_resource: Node2D


var is_boost: bool = false:
	set(new):
		if new:
			max_accel = max_accel * 2.0
		else:
			max_accel = max_accel / 2.0

func _ready() -> void:
	add_to_group("player")
	add_to_group("enemy_targets")
	$MiningTimer.timeout.connect(_mining_timer)
	var life = Life.get_life_script(self)
	if life != null:
		life.on_die.connect(_blow_up)
		life.on_hurt.connect(_on_hurt)
		life.on_health_changed.connect(_on_health_change)
		_on_health_change(life.current_life)

func _blow_up() -> void:
	var explosion_instance = explosion.instantiate()
	if explosion_instance is Node2D:
		explosion_instance.position = position
		explosion_instance.scale *= 2
	died.emit()
	add_sibling(explosion_instance)
	queue_free()

func _on_rb_collision(point: Vector2, normal: Vector2, other: CustomRigidbody2D) -> void:
	var other_life = Life.get_life_script(other)
	if other_life != null:
		other_life.damage(1)
	real_velocity += normal * 200
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if is_entering_blackhole:
		if !$EnterBlackholePlayer.playing:
			$EnterBlackholePlayer.play()
	
	if !is_equal_approx(CustomRigidbody2D.get_global_dt_mult(), 1.0):
		if !$BlackholeLoopPlayer.playing:
			$BlackholeLoopPlayer.play()
	else:
		$BlackholeLoopPlayer.stop()
	

func _custom_physics_process(delta: float) -> void:
	var booster = 0.0
	var rotater = 0.0
	var breaker = 0.0
	
	var game_controller: Game = get_tree().get_first_node_in_group("game_controller")
	
	if Input.is_action_pressed("player_forward",true):
		booster += 1.0
	if Input.is_action_pressed("player_back",true):
		booster -= 1.0
		
	if Input.is_action_pressed("player_back",true) or Input.is_action_pressed("player_forward",true):
		if !$ThrustPlayer.playing:
			$ThrustPlayer.play()
	else:
		$ThrustPlayer.stop()

	if Input.is_action_pressed("player_left", true):
		rotater -= 1
	if Input.is_action_pressed("player_right", true):
		rotater += 1
	if Input.is_action_pressed("player_break", true):
		breaker = 1
	if Input.is_action_just_pressed("player_jump", true) && game_controller.player_boosts > 0:
		var initial_pos = global_position
		global_position += current_forward() * 175
		var new_pos = global_position
		game_controller.player_boosts -= 1
		$JumpPlayer.play()
		
	if Input.is_action_just_pressed("player_collect"):
		connect_to_resource()
	if Input.is_action_just_released("player_collect"):
		disconnect_to_resource()
	_handle_resource_connection()
		
	var linear_drag_val = linear_drag_amount * linear_drag.sample(real_velocity.length() / linear_drag_max_speed)
	var linear_break_val = breaker * max_linear_breaker_power
	var linear_total_slowdown = linear_break_val + linear_drag_val
	
	add_force(get_global_transform().basis_xform(Vector2(0, -booster*max_accel)))
	add_torque(rotater * max_angular_accel)
	
	add_force(-linear_total_slowdown * real_velocity)
	add_torque(-breaker * real_angular_velocity * max_angular_breaker_power - real_angular_velocity * angular_drag_amount)
	

	
func connect_to_resource():
	var resources: Array = get_tree().get_nodes_in_group("resources")
		
	if resources.is_empty():
		return
	
	var closest_distance: float = INF
	var closest_resource: Node2D = null
	for r: Node2D in resources:
		var dist = r.global_position.distance_squared_to(self.global_position)
		if dist < closest_distance:
			closest_distance  = dist
			closest_resource = r
			
	if closest_distance < collection_radius_sqaure:
		connected_resource = closest_resource
		$MiningTimer.wait_time = mine_rate
		$MiningTimer.start()
		$Tether.visible = true
		$MiningLoopPlayer.play()

func disconnect_to_resource():
	connected_resource = null
	$Tether.visible = false
	$MiningTimer.stop()
	$MiningLoopPlayer.stop()
	
func _handle_resource_connection():
	if not connected_resource:
		return
		
	var distance_squared = self.global_position.distance_squared_to(connected_resource.global_position)
	if  distance_squared > collection_radius_sqaure:
		disconnect_to_resource()
		return
	
	var tether: Line2D = $Tether
	tether.clear_points()
	tether.add_point(tether.to_local(self.global_position))
	tether.add_point(tether.to_local(connected_resource.global_position))
	
	var break_ratio = remap(distance_squared, 0, collection_radius_sqaure, 0, 1)
	tether.modulate.b = 1 - break_ratio
	tether.modulate.g = 1 - break_ratio
	
func _mining_timer():
	if not connected_resource or connected_resource.is_queued_for_deletion():
		disconnect_to_resource()
		return
	
	if connected_resource is ResourceAsteroid:
		var mine_response: Array = connected_resource.mine(mine_amount)
		mined.emit(mine_response[1])
		$MinePlayer.play()
		
		
		if mine_response[0]:
			var exp = explosion.instantiate()
			if exp is Node2D:
				exp.global_position = connected_resource.global_position
				add_sibling(exp)
			disconnect_to_resource()
			
	elif connected_resource is SpecialResourceSource:
		if connected_resource.boost > 0:
			var game_controller: Game = get_tree().get_first_node_in_group("game_controller")
			game_controller.player_boosts += connected_resource.boost
		if connected_resource.health > 0:
			var lc = Life.get_life_script(self)
			lc.damage(-connected_resource.health)
		if connected_resource.score > 0:
			var game_controller: Game = get_tree().get_first_node_in_group("game_controller")
			game_controller.score += connected_resource.score

func _on_hurt(to: float) -> void:
	_show_bubble()
	$ShieldHitPlayer.play()
	
func _on_health_change(to: float) -> void:
	var game_controller: Game = get_tree().get_first_node_in_group("game_controller")
	game_controller.update_ui_health(to)

func _show_bubble() -> void:
	var bubble: CanvasItem = $Bubble
	var tw = create_tween()
	bubble.modulate = Color(1,1,1,1)
	tw.tween_property(bubble, "modulate", Color(1,1,1,0), 0.5)
	tw.play()
