extends Node

signal prep_phase_done
signal action_phase_done
signal prep_phase_group_selected(group: UnitGroup)
signal prep_phase_path_selected(path: Node2D)
signal new_group_added(group: UnitGroup, type: String)
signal points_added(points: int)

var hud : HUD
var current_object_held : Node2D
var current_round : int

func emit_prep_phase_done():
	prep_phase_done.emit()


func emit_action_phase_done():
	action_phase_done.emit()


func emit_prep_phase_group_selected(group: UnitGroup):
	prep_phase_group_selected.emit(group)


func emit_prep_phase_path_selected(path: Node2D):
	prep_phase_path_selected.emit(path)


func emit_new_group_added(group: UnitGroup, type: String):
	new_group_added.emit(group, type)
	$"../World/Level".build_groups_container()
	
func emit_points_added(points: int):
	points_added.emit(points)
