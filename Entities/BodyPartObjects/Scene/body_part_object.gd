extends Node2D
class_name BodyPartObject
@export var body_part_resource : BodyPart

var body_type
@onready var sprite_node : Sprite2D = $Sprite2D
@onready var pickupable_component : PickupableComponent = $PickupableComponent

func _ready() -> void:
	pickupable_component.placed_down.connect(on_released)
	initialize_object()
	return

func initialize_object():
	sprite_node.texture = body_part_resource.sprite
	#body_part_resource.body_type is an enum option, so assigning it here outputs an int
	#0 is head, 1 is body, 2 is legs
	body_type = body_part_resource.body_type
	print(body_type)
	return

func on_released():
	var areas = pickupable_component.get_overlapping_areas()
	
	for area in areas:
		if area is Object_Slot:
			print("Found object slot")
			area.store_object_info(self)
			return
	
	return
