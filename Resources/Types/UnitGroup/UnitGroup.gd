class_name UnitGroup extends Resource

@export var unit_scene: PackedScene
@export var unit_data: UnitData
#@export var unit_count: int = 1
#@export var level: int = 1
var target_path: Node2D

#TODO Pass in UnitData that will tell the group what stats to spawn with
