extends CharacterBody2D

class_name CustomRigidbody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	velocity = Vector2(500, 0)
	move_and_slide()


func calculate_time_multiplier() -> float:
	var tds = get_tree().get_nodes_in_group("time_dialaters")
	var total_muliplier = 1.0
	for node in tds:
		if node is TimeDialater:
			total_muliplier *= node.get_multiplier_at(position)
	return total_muliplier
