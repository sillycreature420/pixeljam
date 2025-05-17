extends Node2D
class_name AStar2DNavigator

@export var terrain_layer: TileMapLayer
@export var default_move_cost: float = 1.0
@export var obstacle_cost: float = 1000.0  # Effectively blocks path
@export var cell_size: Vector2 = Vector2(64, 64)
@export var search_radius: int = 3  # Cells to search when finding nearest valid point

var astar := AStar2D.new()
var used_cells: Array[Vector2i] = []

func _ready():
	if terrain_layer == null:
		push_error("AStar2DNavigator requires a TileMapLayer assigned in inspector")
		return
	
	_build_navigation_map()

func _build_navigation_map():
	# Clear previous data
	astar.clear()
	used_cells.clear()
	
	# Get all used cells from the terrain layer
	used_cells = terrain_layer.get_used_cells()
	
	# Add all points to AStar
	for cell in used_cells:
		var id = _cell_to_id(cell)
		var world_pos = _cell_to_world(cell)
		astar.add_point(id, world_pos)
	
	# Connect adjacent cells
	for cell in used_cells:
		var id = _cell_to_id(cell)
		
		# Check all 8 directions for more natural movement
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue  # Skip self
				
				var neighbor = cell + Vector2i(dx, dy)
				var neighbor_id = _cell_to_id(neighbor)
				
				if astar.has_point(neighbor_id):
					# Check if this is an obstacle
					var is_obstacle = terrain_layer.get_cell_source_id(neighbor) != -1
					
					astar.connect_points(id, neighbor_id, true)

func _cell_to_id(cell: Vector2i) -> int:
	# Convert cell coordinates to a unique integer ID
	return cell.x + 100000 * cell.y  # Large multiplier to avoid collisions

func _cell_to_world(cell: Vector2i) -> Vector2:
	# Convert grid coordinates to world position
	return Vector2(cell.x * cell_size.x, cell.y * cell_size.y) + cell_size / 2

func _world_to_cell(world_pos: Vector2) -> Vector2i:
	# Convert world position to grid coordinates
	return Vector2i(
		floori(world_pos.x / cell_size.x),
		floori(world_pos.y / cell_size.y)
	)

func _find_nearest_valid_point(world_pos: Vector2) -> int:
	var center_cell = _world_to_cell(world_pos)
	var best_id = -1
	var best_distance = INF
	
	# Search in expanding concentric squares around the target
	for radius in range(0, search_radius + 1):
		for dx in range(-radius, radius + 1):
			for dy in range(-radius, radius + 1):
				if abs(dx) != radius and abs(dy) != radius:
					continue  # Only check the perimeter
				
				var cell = center_cell + Vector2i(dx, dy)
				var id = _cell_to_id(cell)
				
				if astar.has_point(id):
					var point_pos = astar.get_point_position(id)
					var distance = point_pos.distance_to(world_pos)
					
					if distance < best_distance:
						best_distance = distance
						best_id = id
		
		if best_id != -1:  # Found a valid point
			return best_id
	
	return -1  # No valid point found

func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	if astar.get_point_count() == 0:
		return PackedVector2Array()
	
	# Find nearest valid start and end points
	var start_id = _find_nearest_valid_point(from)
	var end_id = _find_nearest_valid_point(to)
	
	if start_id == -1 or end_id == -1:
		return PackedVector2Array()
	
	# Get the path between valid points
	var grid_path = astar.get_point_path(start_id, end_id)
	
	# Add exact start/end positions if they're not grid-aligned
	if not grid_path.is_empty():
		if from.distance_to(grid_path[0]) > 0.1:
			grid_path.insert(0, from)
		if to.distance_to(grid_path[-1]) > 0.1:
			grid_path.append(to)
	
	return grid_path

func update_navigation_map():
	_build_navigation_map()
