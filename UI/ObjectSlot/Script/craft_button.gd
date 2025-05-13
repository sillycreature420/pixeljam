extends Button

@export var object_slot_1 : Object_Slot
@export var object_slot_2 : Object_Slot
@export var object_slot_3 : Object_Slot

signal CannotCraft

func _ready() -> void:
	pressed.connect(on_button_press)
	return

func on_button_press():
	
	if !object_slot_1.object_held or !object_slot_2.object_held or !object_slot_3.object_held:
		CannotCraft.emit()
	else: craft_unit(object_slot_1.object_held, object_slot_2.object_held, object_slot_3.object_held)
	return

func craft_unit(_part_head_object : BodyPartObject, _part_body_object : BodyPartObject, _part_legs_object : BodyPartObject) -> Unit:
	
	var _part_head : BodyPart =  _part_head_object.body_part_resource
	var _part_body : BodyPart =  _part_body_object.body_part_resource
	var _part_legs : BodyPart =  _part_legs_object.body_part_resource
	
	var new_unit : Unit = Unit.new(_part_head, _part_body, _part_legs)
	
	print(new_unit)
	return new_unit
