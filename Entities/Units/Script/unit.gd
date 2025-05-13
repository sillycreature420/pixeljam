# Base class for units in the game, handles movement, combat, and body part management
extends Node2D
class_name Unit

@export var unit_data : UnitData

# Pathfinding reference - the predefined path this unit will follow
@export var path: Node2D

# Component references
@onready var health_component : HealthComponent = $%HealthComponent  # Health management system
@onready var pathfinding: PathfindingComponent = $PathfindingComponent  # Navigation handler
@onready var attack_cooldown: Timer = $AttackCooldown  # Timer between attacks

# Pathfinding variables
var current_target_path_node: Node2D  # Current node in path being targeted
var path_target_index := 0  # Index tracking progress along path

# Combat variables
var target_obstacle = null  # Current obstacle being attacked (null if none)
var health: float  # Current health
var damage: float = 1.0  # Base damage output
var speed: float  # Movement speed

# Debug input handler
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_spawn"):
		pathfinding.move_to(current_target_path_node.global_position)
		$StateChart.send_event("NewPathFound")


func initialize_unit_data(_unit_data : UnitData):
	assert(_unit_data, name + " initialized without any unit data.")
	
	unit_data = _unit_data
	damage = unit_data.damage #Not sure if you want this to be + or just assigning
	speed = unit_data.speed
	
	return

# Initialize unit stats based on body parts
func initialize_components():
	# Calculate max health from all body part modifiers
	health_component.max_health = unit_data.max_health
	print(health_component.max_health)
	return

# Called when node enters scene tree
func _ready():
	initialize_components()
	# Connect pathfinding completion signal
	pathfinding.target_reached.connect(_target_reached)
	
	# Set initial path target
	if path:
		current_target_path_node = path.get_child(path_target_index)
	else:
		push_error("A unit does not have a path selected!")

# Handle reaching a target (path node or obstacle)
func _target_reached():
	if target_obstacle:
		# If we reached an obstacle, start attacking
		attack_cooldown.start()
		$StateChart.send_event("Attack")
	else:
		# If we reached a path node, advance to next node
		path_target_index += 1
		if path_target_index >= path.get_child_count():
			path_target_index = 0  # Loop path (TODO: Better end handling, not just a loop)
		
		move_to_next_pathfinding_node()
	
	# Always check for nearby obstacles
	if !target_obstacle || target_obstacle.global_position.distance_to(global_position) > 32:
		get_new_target_obstacle()

# Find and target nearest obstacle within range
func get_new_target_obstacle():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		if obstacle.global_position.distance_to(global_position) < 32:
			target_obstacle = obstacle
			# Connect to obstacle's death signal
			if !target_obstacle.health_component.health_below_zero.is_connected(_target_obstacle_destroyed):
				target_obstacle.health_component.health_below_zero.connect(_target_obstacle_destroyed)
			print("found nearby obstacle " + str(obstacle))
			# Move toward the obstacle
			pathfinding.move_to(target_obstacle.global_position)

# Attack cooldown completion handler
func _on_attack_cooldown_timeout() -> void:
	if target_obstacle:
		target_obstacle.health_component.damage(damage)

# Handle obstacle destruction
func _target_obstacle_destroyed():
	# Clean up obstacle references
	target_obstacle.health_component.health_below_zero.disconnect(_target_obstacle_destroyed)
	target_obstacle = null
	attack_cooldown.stop()
	# Look for new obstacles
	get_new_target_obstacle()

# Advance to next node in path
func move_to_next_pathfinding_node():
	# Clean up previous obstacle target if exists
	if target_obstacle:
		if target_obstacle.health_component.health_below_zero.is_connected(_target_obstacle_destroyed):
			target_obstacle.health_component.health_below_zero.disconnect(_target_obstacle_destroyed)
		target_obstacle = null
		
	if path:
		if path_target_index < path.get_child_count():
			# Set new path target and move toward it
			current_target_path_node = path.get_child(path_target_index)
			pathfinding.move_to(current_target_path_node.global_position)
			$StateChart.send_event("NewPathFound")
		else:
			# Handle path completion (#TODO: Implement end of path behaviour)
			pass
