extends Node2D

# Level configuration properties
@export var level_name: String                # Name identifier for this level
@export var level_data: LevelData             # Data asset containing level configuration

# Reference to the group management system
@onready var group_manager_component: Node = $GroupManagerComponent

# Spawn point for units (initialized when level loads)
var spawn_point: Node2D

func _ready() -> void:
	# Connect to global event bus signals
	EventBus.prep_phase_done.connect(start_action_phase)
	LevelManager.transition_completed.connect(_level_loaded)
	
	# Special initialization for first level
	if level_name == "Level One":
		# Create default unit group for new players
		var first_unit_group = UnitGroup.new()
		first_unit_group.unit_count = 1  # Starting with just one unit
		first_unit_group.unit_scene = preload("res://Entities/Units/ZombieUnit/zombie_unit.tscn")
		first_unit_group.unit_leader = UnitLeader.new()  # Create new leader instance
		
		# Add to group manager's tracking system
		group_manager_component.groups.append(first_unit_group)

# TODO: Implement action phase logic
# This should handle:
# - Spawning groups from spawn points
# - Path assignment to unit groups as well as pathfinding node configuration
# - Phase-specific game rules
func start_action_phase():
	pass

# Callback when level transition completes
func _level_loaded():
	# Cache reference to spawn point for later use
	spawn_point = $SpawnPoint
