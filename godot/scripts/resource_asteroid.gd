class_name ResourceAsteroid extends Asteroid

@export var start_amount: float = 5.0

var amount: float

func _ready() -> void:
	super._ready()
	reset_resources()

# returns  [is_dead: bool, mined_amount: float]
func mine(to_mine: float) -> Array:
	var mine_amount = min(to_mine, amount)
	
	amount -= mine_amount
	
	print("Mined ", mine_amount, " with remaining ", amount)

	if is_equal_approx(amount, 0.0):
		queue_free()
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_callback(self.set_modulate.bind(Color.WHITE))

	return [is_equal_approx(amount, 0.0), mine_amount]

func reset_resources() -> void:
	amount = round(start_amount * scale.x * scale.y)
	if amount < 1:
		amount = 1
