class_name ResourceAsteroid extends Asteroid

@export var start_amount: float = 5.0

var amount: float

func _ready() -> void:
	super._ready()
	amount = start_amount
	
func mine(to_mine: float) -> float:
	var mine_amount = min(to_mine, amount)
	
	amount -= mine_amount
	
	print("Mined ", mine_amount, " with remaining ", amount)

	
	if amount == 0:
		queue_free()
	
	return mine_amount
