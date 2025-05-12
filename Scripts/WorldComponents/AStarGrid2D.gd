extends Node2D

@export var grid_size := Vector2i(100, 100)  # Grid dimensions in cells
@export var cell_size := Vector2(16, 16)    # Size of each cell in pixels
@export var default_weight := 1.0           # Default path weight
@export var diagonal_movement := false       # Allow diagonal movement
@export var debug_draw: bool

var astar := AStarGrid2D.new()
var obstacles := []  # Array of grid coordinates that are blocked

@onready var terrain_layer: TileMapLayer = _find_terrain_layer()

func _ready():
	# Initialize the A* grid
	astar.region = Rect2i(Vector2i.ZERO, grid_size)
	astar.cell_size = cell_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER if not diagonal_movement else AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

func _process(_delta: float) -> void:
	pass
	#queue_redraw()

func _find_terrain_layer() -> TileMapLayer:
	print("Finding terrain layer...")
	var level = $"../Level"
	if level:
		for child in level.get_children():
			if child is TileMapLayer and child.name == "Terrain":
				return child
	print("No Terrain layer found!")
	return null

func _process_terrain_tiles():
	print("Processing terrain tiles...")
	if not terrain_layer:
		push_error("No terrain layer to process - Maybe the level hasn't loaded yet?")
		return
	
	var used_cells = terrain_layer.get_used_cells()
	for cell in used_cells:
		var grid_pos = Vector2i(
			cell.x * terrain_layer.tile_set.tile_size.x / cell_size.x,
			cell.y * terrain_layer.tile_set.tile_size.y / cell_size.y
		)
		astar.set_point_solid(grid_pos, true)
		#print("Processed tile at " + str(grid_pos))

func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	var from_grid := world_to_grid(from_world)
	var to_grid := world_to_grid(to_world)
	
	# Check if points are valid
	if not astar.is_in_boundsv(from_grid) or not astar.is_in_boundsv(to_grid):
		return PackedVector2Array()
	
	# Get path as grid coordinates
	var grid_path := astar.get_id_path(from_grid, to_grid)
	
	# Convert to world coordinates
	var world_path := PackedVector2Array()
	for point in grid_path:
		world_path.append(grid_to_world(point))
	
	# Store path for debug drawing
	set_meta("last_path", world_path)
	queue_redraw()
	
	return world_path

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / cell_size)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos) * cell_size + cell_size / 2
	

func _draw():
	if not debug_draw and not get_tree().debug_collisions_hint:
		return
	
	# Draw grid cells
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var grid_pos = Vector2i(x, y)
			var rect_pos = grid_to_world(grid_pos) - cell_size / 2
			var rect = Rect2(rect_pos, cell_size)
			
			# Draw cell background
			var cell_color = Color(0.1, 0.1, 0.1, 0.3)
			if astar.is_point_solid(grid_pos):
				cell_color = Color(0.8, 0.2, 0.2, 0.5)  # Obstacle color
			draw_rect(rect, cell_color, true)
			
			# Draw cell border
			draw_rect(rect, Color(0.3, 0.3, 0.3, 0.5), false, 1.0)
	
	# Draw last calculated path (if any)
	if has_meta("last_path"):
		var path: PackedVector2Array = get_meta("last_path")
		if path.size() > 1:
			for i in range(path.size() - 1):
				draw_line(path[i], path[i+1], Color(0, 1, 0, 0.8), 2.0)
			
			# Draw path points
			for point in path:
				draw_circle(point, 3, Color(0, 1, 0))
				draw_circle(point, 1, Color(1, 1, 1))
