extends Button

@export var shop_slot1 : ShopSlot
@export var shop_slot2 : ShopSlot
@export var shop_slot3 : ShopSlot

@export var label : Label

@export var default_cost : int = 50
@export var cost_increase : int = 20
@export var cost : int = 50

func _ready() -> void:
	pressed.connect(try_reroll)
	EventBus.action_phase_done.connect(reset_reroll)
	cost = default_cost
	update_reroll_text()
	return

func update_reroll_text():
	label.text = str(cost) + " Reroll Cost"
	return

func reset_reroll():
	cost = default_cost
	update_reroll_text()
	return

func increase_reroll():
	cost += cost_increase
	update_reroll_text()
	return

func try_reroll() -> bool:
	if cost > LevelManager.total_points: return false
	
	LevelManager.update_points_total(-cost)
	
	shop_slot1.supply_new_body_part()
	shop_slot2.supply_new_body_part()
	shop_slot3.supply_new_body_part()
	increase_reroll()
	update_reroll_text()
	return true
