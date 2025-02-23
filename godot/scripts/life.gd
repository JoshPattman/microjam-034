extends Node

class_name Life

@export var initial_life: int = 1
@export var debug: bool = false

signal on_die
signal on_hurt

var current_life: float = 0

func _ready() -> void:
	reset_life()

func damage(amount: float) -> void:
	if current_life == 0:
		return
	if debug:
		print(current_life," - ",amount)
	current_life -= amount
	if amount > 0:
		on_hurt.emit(current_life)
	if current_life <= 0:
		current_life = 0
		on_die.emit()

func reset_life() -> void:
	current_life = initial_life

static func get_life_script(node: Node) -> Life:
	if node is Life:
		return node
	for child in node.get_children():
		var l = get_life_script(child)
		if l != null:
			return l
	return null
