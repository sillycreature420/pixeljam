extends Area2D
class_name Object_Slot
#TODO create an object slot, allowing you to place objects on top of the slot, snapping it to the slot and being
#stored to be accessed later (example, creating a new unit)

var object_held : BodyPartObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_pickable = false
	pass # Replace with function body.


func snap_object_to_self():
	object_held.global_position = global_position
	return


#this could be replaced or made more reusable by changing the BodyPartObject to something more general
func store_object_info(new_object : BodyPartObject):
	object_held = new_object
	print(object_held.name)
	snap_object_to_self()
	return


func clear_object_info():
	object_held = null
	return
