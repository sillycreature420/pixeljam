extends Button
class_name ShopSlot


var body_part_being_sold : BodyPart
@onready var shop_texture : TextureRect = $ShopTexture
var cost : int = 0
@export var stats_text : RichTextLabel
@onready var rarity_glow : TextureRect = $RarityGlow


const COMMON_PRICE : int = 100
const UNCOMMON_PRICE : int = 200
const RARE_PRICE : int = 500

func supply_new_body_part():
	body_part_being_sold = PartsManager.generate_new_body_part(PartsManager.calculate_new_type(), PartsManager.calculate_new_rarity(1))
	calculate_cost(body_part_being_sold.rarity)
	update_display()
	return

func _ready() -> void:
	EventBus.action_phase_done.connect(supply_new_body_part)
	pressed.connect(item_purchased)
	#HACK Seeing if this fixes the web version
	supply_new_body_part()
	return

func update_display():
	update_rarity_glow()
	if !body_part_being_sold: shop_texture.texture = null; return
	
	
	shop_texture.texture = body_part_being_sold.sprite
	return

func update_rarity_glow():
	var rarity_glow_texture : GradientTexture2D = GradientTexture2D.new()
	var gradient : Gradient = Gradient.new()
	
	rarity_glow_texture.gradient = gradient
	rarity_glow.texture = rarity_glow_texture
	
	rarity_glow_texture.fill = GradientTexture2D.FILL_RADIAL
	rarity_glow_texture.fill_from = Vector2(0.5, 0.5)
	
	gradient.colors[0] = Color.TRANSPARENT
	gradient.colors[1] = Color.TRANSPARENT
	
	if !body_part_being_sold: gradient.colors[0] = Color.TRANSPARENT; return
	
	if body_part_being_sold.rarity == 0: gradient.colors[0] = Color.BISQUE
	elif body_part_being_sold.rarity == 1: gradient.colors[0] = Color.CHARTREUSE
	elif body_part_being_sold.rarity == 2: gradient.colors[0] = Color.CRIMSON
	
	gradient.colors[0].a = 0.3
	return

func update_stats_text():
	if !body_part_being_sold: stats_text.text = ""; return
	var body_type_text : String
	if body_part_being_sold.body_type == 0: body_type_text = "Skull"
	elif body_part_being_sold.body_type == 1: body_type_text = "Body"
	elif body_part_being_sold.body_type == 2: body_type_text = "Legs"
	
	stats_text.text = "Price: " + str(cost)
	stats_text.text += "\n" + body_part_being_sold.name
	stats_text.text += "\nType: " + body_type_text
	stats_text.text += "\nHealth: " + str(body_part_being_sold.health_modifier)
	stats_text.text += "\nDamage: " + str(body_part_being_sold.damage_modifier)
	stats_text.text += "\nSpeed: " + str(body_part_being_sold.speed_modifier)
	stats_text.text += "\nCount: " + str(body_part_being_sold.count_modifier)
	stats_text.text += "\nAttack Speed: " + str(body_part_being_sold.attack_speed_modifier)
	return


func calculate_cost(_rarity : int):
	if _rarity == 0: cost = COMMON_PRICE
	if _rarity == 1: cost = UNCOMMON_PRICE
	if _rarity == 2: cost = RARE_PRICE
	return

func check_if_item_purchasable() -> bool:
	if cost > LevelManager.total_points: return false
	if body_part_being_sold == null: return false
	return true

func item_purchased():
	if !check_if_item_purchasable(): return
	
	PartsManager.parts.append(body_part_being_sold)
	body_part_being_sold = null
	update_display()
	LevelManager.update_points_total(-cost)
	EventBus.item_purchased_signal.emit()
	return

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_stats_text()
