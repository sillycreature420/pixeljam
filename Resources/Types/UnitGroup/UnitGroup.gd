class_name UnitGroup extends Resource

@export var unit_scene: PackedScene
@export var unit_data: UnitData
#@export var unit_count: int = 1
#@export var level: int = 1
var target_path: Node2D


func _init(
	_unit_scene := load("res://Entities/Units/ZOMBIEUnit/zombie_unit.tscn") , 
	_unit_data := load("res://Resources/Data/UnitData/ZombieUnitData/DebugZombieUnitData.tres")
	) -> void:
	unit_scene = _unit_scene
	unit_data = _unit_data
