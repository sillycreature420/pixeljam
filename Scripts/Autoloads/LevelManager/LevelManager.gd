extends Node

signal transition_started(scene_path)
signal level_loaded(new_scene_root)
signal transition_completed

const TRANSITION_DURATION := 0.5

var _current_level: Node
var current_level_data: LevelData
var level_data: Dictionary[String, LevelData]
var _loading_screen: Control
var loading_screen_scene: PackedScene = preload("res://UI/LoadingScreen/Scene/loading_screen.tscn")
var tile_data: TileMapLayer


func _ready() -> void:
	if is_instance_valid(get_node("../World")):
		_current_level = get_node("../World/Level")
		current_level_data = _current_level.level_data
		level_data.set(_current_level.level_name, _current_level.level_data)
		
		#DEPRECATED
		#tile_data = _current_level.get_node("Data")
		
		await get_tree().process_frame
		level_loaded.emit(_current_level)
	

func change_level(new_scene_path: String) -> void:
	# Get reference to the Game node parent
	var world_node = get_node("../World")
	if not world_node:
		push_error("Game node not found!")
		return
	
	# Get the current Level node
	var current_level = world_node.get_node("Level")
	if not current_level:
		push_error("Level node not found!")
		return
	
	# Emit transition started signal
	transition_started.emit(new_scene_path)
	
	# Show loading screen
	_show_loading_screen()
	
	# Load the new scene asynchronously
	var new_scene = load(new_scene_path) as PackedScene
	if not new_scene:
		push_error("Failed to load scene: ", new_scene_path)
		_hide_loading_screen()
		return
	
	# Create transition effect
	var tween = create_tween()
	tween.tween_property(_loading_screen, "modulate:a", 1.0, TRANSITION_DURATION/2)
	await tween.finished
	
	# Remove old level and its children
	current_level.queue_free()
	await current_level.tree_exited
	
	# Instantiate and add new level
	var new_level = new_scene.instantiate()
	world_node.add_child(new_level)
	world_node.move_child(new_level, world_node.get_children().find(current_level))
	
	# Update references
	_current_level = new_level
	if !level_data.has(_current_level.level_name):
		current_level_data = _current_level.level_data
	else:
		current_level_data = level_data.get(_current_level.level_name)
		print("Current level's containers: " + str(current_level_data.containers))
		print("Current level's enemies: " + str(current_level_data.enemies))
	
	#DEPRECATED
	#tile_data = new_level.get_node("Data") as TileMapLayer
	#if not tile_data:
		#push_warning("New level missing TileMapLayer 'Data'")
	
	# Complete transition
	level_loaded.emit(new_level)
	
	tween = create_tween()
	tween.tween_property(_loading_screen, "modulate:a", 0.0, TRANSITION_DURATION/2)
	await tween.finished
	_hide_loading_screen()
	
	transition_completed.emit()

func _show_loading_screen():
	if not _loading_screen:
		_loading_screen = loading_screen_scene.instantiate()
		get_tree().root.add_child(_loading_screen)
	_loading_screen.show()

func _hide_loading_screen():
	if _loading_screen:
		_loading_screen.hide()
