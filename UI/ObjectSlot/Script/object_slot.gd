extends Area2D
class_name Object_Slot

var object_held : BodyPartObject

func _ready() -> void:
	input_pickable = false

func snap_object_to_self():
	object_held.global_position = global_position
	return

#this could be replaced or made more reusable by changing the BodyPartObject to something more general
func store_object_info(new_object : BodyPartObject):
	if object_held: print("Rejecting item! A previous item is already stored."); return
	
	
	object_held = new_object
	
	object_held.pickupable_component.picked_up.connect(clear_object_info)
	snap_object_to_self()
	return


func clear_object_info():
	object_held.pickupable_component.picked_up.disconnect(clear_object_info)
	object_held = null
	return
