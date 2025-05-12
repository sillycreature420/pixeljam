extends Node

@export var groups: Array[UnitGroup]

var currently_selected_group: UnitGroup


func _ready() -> void:
	# Connect to relevant EventBus signals
	EventBus.new_group_added.connect(_new_group_added)


func assign_path(group: UnitGroup, path: Node2D):
	group.target_path = path

func _new_group_added(group: UnitGroup):
	groups.append(group)
