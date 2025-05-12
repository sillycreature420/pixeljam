extends Node2D

@export var unit_container: Node2D

@onready var spawn_location: Node2D = $SpawnLocation

func spawn_group(group: UnitGroup):
	var target_path = group.target_path
	var unit_scene = group.unit_scene
	for i in range(group.unit_count):
		var new_unit = unit_scene.instantiate()
		new_unit.path = target_path
		new_unit.global_position = spawn_location.global_position
		unit_container.add_child(new_unit)
