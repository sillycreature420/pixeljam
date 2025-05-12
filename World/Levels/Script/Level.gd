extends Node2D

@export var level_name: String
@export var level_data: LevelData

var spawn_point: Node2D

func _ready() -> void:
	EventBus.prep_phase_done.connect(start_action_phase)
	LevelManager.transition_completed.connect(_level_loaded)

#TODO Action phase: spawner logic, establish paths with pathfinding nodes
func start_action_phase():
	pass

func _level_loaded():
	spawn_point = $SpawnPoint
