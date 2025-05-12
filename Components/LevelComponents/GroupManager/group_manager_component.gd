extends Node

@export var groups: Array[UnitGroup]

var currently_selected_group: UnitGroup


func _ready() -> void:
	pass


func assign_path(group: UnitGroup, path: Node2D):
	group.target_path = path
