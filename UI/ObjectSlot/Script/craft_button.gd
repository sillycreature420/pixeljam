extends Button

@export var object_slot_1 : Object_Slot
@export var object_slot_2 : Object_Slot
@export var object_slot_3 : Object_Slot

##Useful for adding graphics/sounds/polish
signal CannotCraft

var scene = preload("res://Entities/Units/Scene/Unit.tscn")

func _ready() -> void:
	pressed.connect(on_button_press)
	return

func on_button_press():
	##Checks if there is objects in the slots
	if !object_slot_1.object_held or !object_slot_2.object_held or !object_slot_3.object_held:
		CannotCraft.emit()
		print("Attempted to craft, but there was not enough objects in the slots")
	else: 
		var new_unit_data = craft_unit_data(object_slot_1.object_held, object_slot_2.object_held, object_slot_3.object_held)
		instantiate_new_unit(new_unit_data)
	
	
	return

##Returns a new unit data with the parts from the slots assigned
func craft_unit_data(_part_head_object : BodyPartObject, _part_body_object : BodyPartObject, _part_legs_object : BodyPartObject) -> UnitData:
	
	var _part_head : BodyPart =  _part_head_object.body_part_resource
	var _part_body : BodyPart =  _part_body_object.body_part_resource
	var _part_legs : BodyPart =  _part_legs_object.body_part_resource
	
	var new_unit_data : UnitData = UnitData.new(_part_head, _part_body, _part_legs)
	
	return new_unit_data

##Useless test function, should be replaced with creating a new group to be used else where
func instantiate_new_unit(_new_unit_data :UnitData):
	var new_instance = scene.instantiate()
	if !new_instance is Unit:
		return
		
	new_instance.initialize_unit_data(_new_unit_data)
	add_child(new_instance)
	return
