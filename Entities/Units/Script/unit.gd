extends Node2D

@export var path: Node2D

@onready var pathfinding: PathfindingComponent = $PathfindingComponent

var current_target_path_node: Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_spawn"):
		pathfinding.move_to(current_target_path_node.global_position)


func _ready():
	current_target_path_node = path.get_child(0)
