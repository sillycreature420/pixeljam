class_name PathfindingComponent extends Node2D

@export var move_speed := 150.0
var current_path: PackedVector2Array = []
var target_position: Vector2

@onready var astar_grid := $"/root/World/AStarGrid2D"  # Adjust path to your AStarGrid2D node

func _physics_process(_delta):
	if current_path.is_empty():
		return
	
	var next_point := current_path[0]
	var direction := (next_point - global_position).normalized()
	var safe_velocity = direction * move_speed
	
	if is_instance_valid(get_parent()) and get_parent() is Node2D:
		var parent = get_parent() as Node2D
		parent.position += safe_velocity * get_process_delta_time()
	
	if global_position.distance_to(next_point) < 1.0:
		current_path.remove_at(0)

func move_to(target: Vector2):
	target_position = target
	current_path = astar_grid.find_path(global_position, target_position)
