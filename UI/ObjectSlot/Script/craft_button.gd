extends Button

@export var object_slot_1 : Object_Slot
@export var object_slot_2 : Object_Slot
@export var object_slot_3 : Object_Slot

var held_unit_data : UnitData
##Useful for adding graphics/sounds/polish
signal CannotCraft

var scene = preload("res://Entities/Units/Scene/Unit.tscn")

func _ready() -> void:
	pressed.connect(on_button_press)
	return

func on_button_press():
	
	if !GroupManager.currently_selected_group: print("No group was selected"); CannotCraft.emit(); return
	
	##Checks if there is objects in the slots
	if !object_slot_1.object_held or !object_slot_2.object_held or !object_slot_3.object_held:
		CannotCraft.emit()
		print("Attempted to craft, but there was not enough objects in the slots")
	else: 
		held_unit_data = craft_unit_data(object_slot_1.object_held, object_slot_2.object_held, object_slot_3.object_held)
		
		call_assign_unit_data.call_deferred()
	
	return

func call_assign_unit_data():
	print(held_unit_data.speed)
	GroupManager.assign_unit_data(GroupManager.currently_selected_group, held_unit_data)
	return

##Returns a new unit data with the parts from the slots assigned
func craft_unit_data(_part_head : BodyPart, _part_body : BodyPart, _part_legs : BodyPart) -> UnitData:
	
	print(_part_head.speed_modifier)
	print(_part_body.speed_modifier)
	print(_part_legs.speed_modifier)
	
	var new_unit_data : UnitData = UnitData.new(_part_head, _part_body, _part_legs)
	consume_parts([_part_head, _part_body, _part_legs])
	
	return new_unit_data


func consume_parts(array_of_parts : Array[BodyPart]):
	
	for part in array_of_parts:
		print("Removing part")
		PartsManager.parts.erase(part)
		pass
	
	object_slot_1.clear_object_info()
	object_slot_2.clear_object_info()
	object_slot_3.clear_object_info()
	
	if PartsManager.parts.size() <= 0: PartsManager.no_more_parts.emit()
	return
