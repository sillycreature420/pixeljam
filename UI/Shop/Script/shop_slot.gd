extends Button
class_name ShopSlot

var body_part_being_sold : BodyPart
@onready var shop_texture : TextureRect = $ShopTexture
var cost : int

func supply_new_body_part():
	body_part_being_sold = PartsManager.generate_new_body_part(PartsManager.calculate_new_type(), PartsManager.calculate_new_rarity(1))
	update_display()
	return

func _ready() -> void:
	EventBus.action_phase_done.connect(supply_new_body_part)
	pressed.connect(item_purchased)
	supply_new_body_part()
	return

func update_display():
	shop_texture.texture = body_part_being_sold.sprite
	return

func calculate_cost(_rarity : int):
	if _rarity == 0: cost = 300
	if _rarity == 1: cost = 800
	if _rarity == 2: cost = 2000
	return

func check_if_item_purchasable() -> bool:
	if cost > LevelManager.total_points: return false
	return true

func item_purchased():
	if !check_if_item_purchasable(): return
	
	LevelManager.total_points -= cost
	PartsManager.parts.append(body_part_being_sold)
	body_part_being_sold = null
	return
