extends Button

@export var shop_slot1 : ShopSlot
@export var shop_slot2 : ShopSlot
@export var shop_slot3 : ShopSlot

@export var cost : int = 50

func _ready() -> void:
	pressed.connect(try_reroll)
	return
	
func try_reroll() -> bool:
	if cost > LevelManager.total_points: return false
	
	LevelManager.update_points_total(-cost)
	
	shop_slot1.supply_new_body_part()
	shop_slot2.supply_new_body_part()
	shop_slot3.supply_new_body_part()
	return true
