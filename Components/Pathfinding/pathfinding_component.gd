class_name PathfindingComponent extends Node2D

signal target_reached

@export var move_speed := 30.0
@export var target_easing := 1.0
@export var astar_implementation: bool # True for grid
var current_path: PackedVector2Array = []
var target_position: Vector2

@onready var astar_grid := $"/root/World/AStarGrid2D"
@onready var astar := $"/root/World/AStar2D"

func _physics_process(delta):
	if current_path.is_empty():
		return
	
	var next_point := current_path[0]
	# Adjust points to account for grid origin top left
	next_point = next_point - Vector2(8, 8)
	
	var direction := (next_point - global_position).normalized()
	var safe_velocity = direction * move_speed
	
	if is_instance_valid(get_parent()) and get_parent() is Node2D:
		var parent = get_parent() as Node2D
		parent.position += safe_velocity * delta
	
	#FIXME Easing is problematic, leads to diagonal movement (sometimes thru walls)
	if global_position.distance_to(next_point) < target_easing:
		current_path.remove_at(0)
		
	if current_path.size() == 0:
		target_reached.emit()
		#print("Target reached")

func move_to(target: Vector2):
	target_position = target
	if astar_implementation:
		current_path = astar_grid.find_path(global_position, target_position)
	else:
		current_path = astar.find_path(global_position, target_position)
