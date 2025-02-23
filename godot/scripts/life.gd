extends Node

class_name Life

@export var initial_life: int = 1

signal on_die

var current_life: int = 0

func _ready() -> void:
	reset_life()

func damage(amount: int) -> void:
	if current_life == 0:
		return
	current_life -= amount
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
