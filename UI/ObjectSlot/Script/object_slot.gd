extends Area2D
class_name Object_Slot

signal object_info_stored()

@export var default_texture : Texture

@onready var slot_texture: TextureRect = $SlotTexture
var object_held : BodyPart


func _ready() -> void:
	input_pickable = false


func snap_object_to_self():
	#object_held.global_position = global_position
	return


#this could be replaced or made more reusable by changing the BodyPartObject to something more general
func store_object_info(new_part : BodyPart):
	if object_held: print("Rejecting item! A previous item is already stored."); return
	
	
	object_held = new_part
	slot_texture.texture = object_held.sprite
	
	object_info_stored.emit()
	#object_held.pickupable_component.picked_up.connect(clear_object_info)
	snap_object_to_self()
	return


func clear_object_info():
	object_held = null
	slot_texture.texture = default_texture
	return
