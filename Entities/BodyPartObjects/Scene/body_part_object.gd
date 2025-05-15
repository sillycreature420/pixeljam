extends Node2D
class_name BodyPartObject

@export var body_part_resource : BodyPart
@export var default_sprite : Texture

@onready var sprite_node : Sprite2D = $Sprite2D
@onready var pickupable_component : PickupableComponent = $PickupableComponent
var body_type
var no_more_parts : bool = false
func _ready() -> void:
	pickupable_component.placed_down.connect(on_released)
	PartsManager.no_more_parts.connect(set_to_default)
	
	initialize_object.call_deferred()
	return

func set_to_default():
	body_part_resource = null
	sprite_node.texture = default_sprite
	print("setting object to default")
	return

func initialize_object():
	if !body_part_resource: body_part_resource = PartsManager.parts[0]; PartsManager.selected_part = 0
	sprite_node.texture = body_part_resource.sprite
	#body_part_resource.body_type is an enum option, so assigning it here outputs an int
	#0 is head, 1 is body, 2 is legs
	body_type = body_part_resource.body_type
	#print(body_type)
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
			#print("Found object slot")
			if area.store_object_info(self.body_part_resource): change_resource(PartsManager.selected_part + 1)
			return
	
	return
