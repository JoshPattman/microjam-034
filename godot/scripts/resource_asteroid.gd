class_name ResourceAsteroid extends Asteroid

@export var start_amount: float = 5.0

var amount: float

func _ready() -> void:
	super._ready()
	amount = start_amount

# returns  [is_dead: bool, mined_amount: float]
func mine(to_mine: float) -> Array:
	var mine_amount = min(to_mine, amount)
	
	amount -= mine_amount
	
	print("Mined ", mine_amount, " with remaining ", amount)

	if is_equal_approx(amount, 0.0):
		queue_free()
	
	return [is_equal_approx(amount, 0.0), mine_amount]
