extends Node

signal prep_phase_done
signal prep_phase_group_selected(group: UnitGroup)
signal prep_phase_path_selected(path: Node2D)

var current_object_held : Node2D

func emit_prep_phase_done():
	prep_phase_done.emit()

func emit_prep_phase_group_selected(group: UnitGroup):
	prep_phase_group_selected.emit(group)

func emit_prep_phase_path_selected(path: Node2D):
	prep_phase_path_selected.emit(path)
