extends Node

signal prep_phase_done
signal prep_phase_group_selected(group: UnitGroup)
signal prep_phase_path_select(path: Node2D)

var current_object_held : Node2D
