extends Node2D
class_name BodyPartObject

@export var body_part_resource : BodyPart
@export var default_sprite : Texture
@export var stats_text : RichTextLabel

@onready var sprite_node : Sprite2D = $Sprite2D
@onready var pickupable_component : PickupableComponent = $PickupableComponent
@onready var rarity_glow : TextureRect = $RarityGlow
var body_type
var no_more_parts : bool = false

func _ready() -> void:
	set_to_default()
	pickupable_component.placed_down.connect(on_released)
	PartsManager.no_more_parts.connect(set_to_default)
	EventBus.item_purchased_signal.connect(switch_to_new_resource)
	
	initialize_object.call_deferred()
	return

func set_to_default():
	body_part_resource = null
	sprite_node.texture = default_sprite
	print("setting object to default")
	return

func initialize_object():
	update_rarity_glow()
	if !body_part_resource: return
	sprite_node.texture = body_part_resource.sprite
	#body_part_resource.body_type is an enum option, so assigning it here outputs an int
	#0 is head, 1 is body, 2 is legs
	body_type = body_part_resource.body_type
	
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
	
	if !body_part_resource: gradient.colors[0] = Color.TRANSPARENT; return
	
	if body_part_resource.rarity == 0: gradient.colors[0] = Color.BISQUE
	elif body_part_resource.rarity == 1: gradient.colors[0] = Color.CHARTREUSE
	elif body_part_resource.rarity == 2: gradient.colors[0] = Color.CRIMSON
	
	gradient.colors[0].a = 0.2
	return


func switch_to_new_resource():
	change_resource(PartsManager.parts.size() - 1)
	return

func change_resource(parts_index : int):
	if PartsManager.parts.size() - 1 < parts_index:
		if PartsManager.parts.size() == 0: PartsManager.no_more_parts.emit()
		else: parts_index = 0
	
	
	body_part_resource = PartsManager.parts[parts_index]
	PartsManager.selected_part = parts_index
	initialize_object()
	return

func on_released():
	var areas = pickupable_component.get_overlapping_areas()
	
	for area in areas:
		if area is Object_Slot:
			if area.body_type == body_part_resource.body_type:
				if area.store_object_info(self.body_part_resource): change_resource(PartsManager.selected_part + 1); return
	return

func update_stats_text():
	if !body_part_resource: stats_text.text = ""; return
	var body_type_text : String
	if body_part_resource.body_type == 0: body_type_text = "Head"
	elif body_part_resource.body_type == 1: body_type_text = "Body"
	elif body_part_resource.body_type == 2: body_type_text = "Legs"
	
	stats_text.text = ""
	stats_text.text += "\n" + body_part_resource.name
	stats_text.text += "\nType: " + body_type_text
	stats_text.text += "\nHealth: " + str(body_part_resource.health_modifier)
	stats_text.text += "\nDamage: " + str(body_part_resource.damage_modifier)
	stats_text.text += "\nSpeed: " + str(body_part_resource.speed_modifier)
	stats_text.text += "\nCount: " + str(body_part_resource.count_modifier)
	stats_text.text += "\nAttack Speed: " + str(body_part_resource.attack_speed_modifier)
	return

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_stats_text()
	return
