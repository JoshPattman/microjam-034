extends CustomRigidbody2D

class_name Enemy

var current_target: Node2D
@export var speed: float = 200
@export var angular_speed: float = 5
@export var drag: float = 0.01

var target_direction: Vector2

@export var k_targeting = 1
@export var k_avoiding = 0.5
@export var k_separate = 0.5

@export var separate_radius = 50

@export var is_kamikazee: bool = false
@export var kamikazee_range: float = 40
@export var kamikazee_explosion: PackedScene
@export var kamikazee_damage: int = 1

@export var orbit_dist: float = 300

@export var spawn_ship: PackedScene
@export var spawn_delay: float = 2.0
var spawn_timer: float = 0.0

var things_to_avoid: Array[EnemyAvoid] = []
var enemies_in_range: Array[Enemy] = []
var recalc_avoids_timer: float = 0.0
var recalc_avoids_every: float = 0.25

func _on_rb_collision(point: Vector2, normal: Vector2, other: CustomRigidbody2D) -> void:
	var other_life = Life.get_life_script(other)
	if other_life != null:
		other_life.damage(kamikazee_damage)
	if other is Asteroid:
		real_velocity += normal * 75

func _ready() -> void:
	add_to_group("enemies")
	recalc_avoids_timer = randf_range(0, recalc_avoids_every)
	var life = Life.get_life_script(self)
	if life != null:
		life.on_die.connect(blow_up)

func _custom_process(delta: float) -> void:
	$AnimationPlayer.speed_scale = CustomRigidbody2D.get_global_dt_mult()

	if current_target == null:
		current_target = get_next_target()
	
	var d_target: Vector2
	if current_target != null:
		if is_kamikazee:
			d_target = (current_target.global_position - global_position).normalized()
		else:
			var target_delta = current_target.global_position - global_position
			# T is 0 when close and 1 when far
			var t = tanh((target_delta.length() - orbit_dist) / 100)/2+0.5
			var target_norm_delta = target_delta.normalized()
			var target_orbit_delta = target_norm_delta.rotated(PI/2)
			d_target = ((1-t)*target_orbit_delta + t*target_norm_delta).normalized()
	
	if recalc_avoids_timer >= recalc_avoids_every:
		var avoids = get_tree().get_nodes_in_group("enemy_avoid")
		things_to_avoid.clear()
		for a in avoids:
			if a != null && a is EnemyAvoid:
				things_to_avoid.append(a)
		var enems = get_tree().get_nodes_in_group("enemies")
		enemies_in_range.clear()
		for e in enems:
			if e != null && e is Enemy && e != self:
				enemies_in_range.append(e)
		recalc_avoids_timer = 0
	recalc_avoids_timer += delta
	
	var d_separate = Vector2()
	for e in enemies_in_range:
		if e == null:
			continue
		var e_delta = e.global_position - global_position
		var e_dist = e_delta.length()
		if e_dist > separate_radius:
			continue
		d_separate -= (e_delta/e_dist) * (1 - (e_dist/separate_radius))
	if d_separate.length() > 1:
		d_separate = d_separate.normalized()
	
	var d_avoid = Vector2()
	for a in things_to_avoid:
		if a == null:
			continue
		var a_delta = a.global_position - global_position
		var a_dist = a_delta.length()
		if a_dist > a.radius:
			continue
		d_avoid -= (a_delta/a_dist) * (1 - (a_dist/a.radius)) * a.weight
	if d_avoid.length() > 1:
		d_avoid = d_avoid.normalized()
	
	if current_target != null:
		if is_kamikazee:
			if (global_position - current_target.global_position).length() < kamikazee_range:
				blow_up()
				var lc = Life.get_life_script(current_target)
				if lc != null:
					lc.damage(kamikazee_damage)
		else:
			if spawn_timer > spawn_delay:
				spawn_timer = 0
				var ins = spawn_ship.instantiate()
				if ins is Node2D:
					ins.global_position = global_position - current_forward()*30
				add_sibling(ins)
	
	target_direction = d_target*k_targeting + d_avoid*k_avoiding + d_separate*k_separate
	if target_direction.length() > 1:
		target_direction = target_direction.normalized()
	spawn_timer += delta * CustomRigidbody2D.get_global_dt_mult()

func blow_up():
	var exp = kamikazee_explosion.instantiate()
	if exp is Node2D:
		exp.global_position = global_position
		exp.scale *= 2
	add_sibling(exp)
	queue_free()

func _custom_physics_process(delta: float) -> void:
	if target_direction == Vector2():
		return
	var angle_to_target = target_direction.angle_to(current_forward())
	add_force(target_direction * speed)
	add_force(-real_velocity * real_velocity.length() * drag)
	real_angular_velocity = -angle_to_target * angular_speed

func get_next_target() -> Node2D:
	var targets = get_tree().get_nodes_in_group("enemy_targets")
	var closest_target: Node2D
	var closest_dist: float = 99999999999.0
	for t in targets:
		if t is Node2D:
			var dist = (t.global_position - global_position).length()
			if dist < closest_dist:
				closest_dist = dist
				closest_target = t
	return closest_target
