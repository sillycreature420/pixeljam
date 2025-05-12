extends Node

# Signals for tracking level transition states
signal transition_started(scene_path)      # Emitted when level change begins
signal level_loaded(new_scene_root)        # Emitted when new level is ready
signal transition_completed                # Emitted when all transition effects finish

# Configuration
const TRANSITION_DURATION := 0.5           # Duration (in seconds) for fade effects

# Level Management
var _current_level: Node                   # Reference to currently active level
var current_level_data: LevelData          # Data asset for current level
var level_data: Dictionary[String, LevelData]  # Collection of all level data
var _loading_screen: Control               # Reference to loading screen instance
var loading_screen_scene: PackedScene = preload("res://UI/LoadingScreen/Scene/loading_screen.tscn")

# DEPRECATED - Kept for potential backward compatibility
var tile_data: TileMapLayer

func _ready() -> void:
	# Initialize current level references if world exists
	if is_instance_valid(get_node("../World")):
		_current_level = get_node("../World/Level")
		current_level_data = _current_level.level_data
		
		# Store level data in dictionary for later access
		level_data.set(_current_level.level_name, _current_level.level_data)
		
		# Wait one frame to ensure everything is loaded
		await get_tree().process_frame
		
		# Notify other systems that initial level is ready
		level_loaded.emit(_current_level)


# Handles transitioning between levels
# @param new_scene_path: Path to the packed scene for the new level
func change_level(new_scene_path: String) -> void:
	# Validate world node exists
	var world_node = get_node("../World")
	if not world_node:
		push_error("Game node not found!")
		return
	
	# Validate current level exists
	var current_level = world_node.get_node("Level")
	if not current_level:
		push_error("Level node not found!")
		return
	
	# Begin transition process
	transition_started.emit(new_scene_path)
	_show_loading_screen()
	
	# Load new level scene
	var new_scene = load(new_scene_path) as PackedScene
	if not new_scene:
		push_error("Failed to load scene: ", new_scene_path)
		_hide_loading_screen()
		return
	
	# Create fade-in transition effect
	var tween = create_tween()
	tween.tween_property(_loading_screen, "modulate:a", 1.0, TRANSITION_DURATION/2)
	await tween.finished
	
	# Clean up old level
	current_level.queue_free()
	await current_level.tree_exited
	
	# Instantiate and position new level
	var new_level = new_scene.instantiate()
	world_node.add_child(new_level)
	world_node.move_child(new_level, world_node.get_children().find(current_level))
	
	# Update level references and data
	_current_level = new_level
	if !level_data.has(_current_level.level_name):
		current_level_data = _current_level.level_data
	else:
		current_level_data = level_data.get(_current_level.level_name)
		print("Current level's containers: " + str(current_level_data.containers))
		print("Current level's enemies: " + str(current_level_data.enemies))
	
	# Update pathfinding for new level
	var pathfinding = world_node.get_node("AStarGrid2D")
	pathfinding.terrain_layer = pathfinding._find_terrain_layer()
	pathfinding._process_terrain_tiles()
	
	# Complete transition
	level_loaded.emit(new_level)
	
	# Create fade-out transition effect
	tween = create_tween()
	tween.tween_property(_loading_screen, "modulate:a", 0.0, TRANSITION_DURATION/2)
	await tween.finished
	_hide_loading_screen()
	
	transition_completed.emit()


# Creates and shows the loading screen overlay
func _show_loading_screen():
	if not _loading_screen:
		_loading_screen = loading_screen_scene.instantiate()
		get_tree().root.add_child(_loading_screen)
	_loading_screen.show()


# Hides the loading screen overlay
func _hide_loading_screen():
	if _loading_screen:
		_loading_screen.hide()
