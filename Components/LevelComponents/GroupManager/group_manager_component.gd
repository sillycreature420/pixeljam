extends Node

@export var groups: Array[UnitGroup]

var currently_selected_group: UnitGroup


func _ready() -> void:
	pass


#TODO Link assign_path function to button in HUD using currently selected group	
func assign_path(group: UnitGroup, path: Node2D):
	group.target_path = path
