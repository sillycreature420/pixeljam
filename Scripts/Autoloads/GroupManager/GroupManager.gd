extends Node

@export var groups: Array[UnitGroup]

var currently_selected_group: UnitGroup


func _ready() -> void:
	# Connect to relevant EventBus signals
	EventBus.new_group_added.connect(_new_group_added)


func assign_path(group: UnitGroup, path: Node2D):
	group.target_path = path


func assign_unit_data(group: UnitGroup, unit_data: UnitData):
	group.unit_data = unit_data


func _new_group_added(group: UnitGroup, type: String):
	var type_lower = type.to_lower()
	group.unit_scene = load("res://Entities/Units/" + type + "Unit/" + type_lower + "_unit.tscn")
	groups.append(group)
