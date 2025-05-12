extends Node2D

# Level configuration properties
@export var level_name: String                # Name identifier for this level
@export var level_data: LevelData             # Data asset containing level config and info
@export var paths: Array[Node2D]              # Array of currently available paths in this level


@onready var hud: Control = $"../UILayer/HUD"

# Reference to the group management system (initialized when level loads)
var group_manager_component: Node

# Spawn point for units (initialized when level loads)
var spawn_point: Node2D

func _ready() -> void:
	# Connect to global event bus signals
	EventBus.prep_phase_done.connect(start_action_phase)
	LevelManager.transition_completed.connect(_level_loaded)
	
# TODO: Implement action phase logic
# This should handle:
# - Spawning groups from spawn points
# - Path assignment to unit groups as well as pathfinding node configuration
# - Phase-specific game rules
func start_action_phase():
	# Spawn units
	spawn_point.spawn_group(group_manager_component.groups[0])
	
	
# Callback when level transition completes
func _level_loaded():
	# Cache reference to spawn point for later use
	spawn_point = $SpawnPoint
	group_manager_component = $GroupManagerComponent
	
	# Special initialization for first level
	if level_name == "Level One":
		# Create default unit group for new players
		var first_unit_group = UnitGroup.new()
		first_unit_group.unit_count = 1  # Starting with just one unit
		first_unit_group.unit_scene = preload("res://Entities/Units/ZombieUnit/zombie_unit.tscn")
		first_unit_group.unit_leader = UnitLeader.new()  # Create new leader instance
		
		# Add to group manager's tracking system
		group_manager_component.groups.append(first_unit_group)
		
	build_groups_container()
		
	build_paths_container()


func _group_selected(group):
	group_manager_component.currently_selected_group = group
	EventBus.emit_prep_phase_group_selected(group)
	print(str(group) + " selected")


func _path_selected(path):
	group_manager_component.assign_path(group_manager_component.currently_selected_group, path)
	EventBus.emit_prep_phase_path_selected(path)
	print(str(path) + " assigned to group " + str(group_manager_component.currently_selected_group))


func build_groups_container():
	# Clear the current group buttons
	for child in hud.groups_container.get_children():
		child.queue_free()
	
	# Add buttons for each group found in the group manager component
	for group in group_manager_component.groups:
		var new_group_button = Button.new()
		new_group_button.text = "Group " + str(group_manager_component.groups.find(group) + 1)
		
		new_group_button.pressed.connect(_group_selected.bind(group))
		
		hud.groups_container.add_child(new_group_button)
		
func build_paths_container():
	# Clear the current path buttons
	for child in hud.paths_container.get_children():
		child.queue_free()
	
	# Add buttons for each path found in the paths property
	for path in paths:
		var new_path_button = Button.new()
		new_path_button.text = "Path " + str(paths.find(path) + 1)
		
		new_path_button.pressed.connect(_path_selected.bind(path))
		
		hud.paths_container.add_child(new_path_button)
