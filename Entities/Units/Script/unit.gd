# Base class for units in the game, handles movement, combat, and body part management
extends Area2D
class_name Unit

@export var unit_data : UnitData

# Pathfinding reference - the predefined path this unit will follow
@export var path: Node2D

#Graphics
@export var animated_head : AnimatedSprite2D
@export var animated_body : AnimatedSprite2D
@export var animated_legs : AnimatedSprite2D

# Component references
@onready var health_component : HealthComponent = $HealthComponent  # Health management system
#@onready var pathfinding: PathfindingComponent = $PathfindingComponent  # Navigation handler
@export var attack_cooldown: Timer  # Timer between attacks
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# Pathfinding variables
var current_target_path_node: Node2D  # Current node in path being targeted
var path_target_index := 0  # Index tracking progress along path
var next_pos: Vector2
var movement_delta: float
var targeting_goal: bool = false

# Combat variables
var target_obstacle = null  # Current obstacle being attacked (null if none)
var health: float  # Current health
var damage: float = 1.0  # Base damage output
var base_speed: float = 8.0 # Base movement speed in pixels
var speed: float  # Movement speed as a multiplier


func _physics_process(delta: float) -> void:
	# Set speed and update desired position
	movement_delta = speed * delta
	next_pos = nav_agent.get_next_path_position()
	
	var new_velocity: Vector2 = global_position.direction_to(next_pos) * movement_delta
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func initialize_unit_data(_unit_data : UnitData):
	assert(_unit_data, name + " initialized without any unit data.")
	
	unit_data = _unit_data
	
	unit_data.initialize_unit_stats()
	
	health = unit_data.max_health

	damage = unit_data.damage #Not sure if you want this to be + or just assigning / Assigning is fine - Cam
	speed = unit_data.speed * base_speed
	attack_cooldown.wait_time = 1 / unit_data.attack_speed
	
	initialize_unit_graphics()
	return

func initialize_unit_graphics():
	animated_head.sprite_frames = unit_data.head_part.sprite_frames
	animated_body.sprite_frames = unit_data.body_part.sprite_frames
	animated_legs.sprite_frames = unit_data.legs_part.sprite_frames
	
	animated_head.sprite_frames.set_animation_speed("default", unit_data.attack_speed)
	animated_body.sprite_frames.set_animation_speed("default", unit_data.attack_speed)
	animated_legs.sprite_frames.set_animation_speed("default", unit_data.attack_speed)
	
	animated_head.play()
	animated_body.play()
	animated_legs.play()
	return

# Initialize unit stats based on body parts
func initialize_components():
	# Calculate max health from all body part modifiers
	health_component.max_health = unit_data.max_health
	return

# Called when node enters scene tree
func _ready():
	initialize_components()
	initialize_unit_data(unit_data)
	# Connect pathfinding completion signal
	#DEPRECATED
	#pathfinding.target_reached.connect(_target_reached)
	nav_agent.navigation_finished.connect(_target_reached)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	# Set up health component
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.health_below_zero.connect(_on_death)
	health_component.set_max_health(health)
	health_component.set_health_to_max_health()
	# Set initial path target
	if path:
		current_target_path_node = path.get_child(path_target_index)
	else:
		push_error("A unit does not have a path selected!")


func _on_velocity_computed(safe_velocity: Vector2):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)


func check_if_final_unit():
	var all_units = get_parent().get_children()
	if all_units.size() <= 1:
		#Do round end logic here
		print("everyone is dead!")
		EventBus.emit_action_phase_done()
		EventBus.hud.preparing_scene.show()
		EventBus.hud.playing_scene.hide()
	return

# Handle reaching a target (path node or obstacle)
func _target_reached():
	if targeting_goal:
		for goal in get_tree().get_nodes_in_group("goal"):
			goal.unit_reached_goal(damage)
		
		#HACK Unit takes 1000 damage when it reaches the goal instead of just queue_free()
		health_component.damage(1000.0)
	
	# Always check for nearby obstacles
	if !target_obstacle || target_obstacle.global_position.distance_to(global_position) > 32:
		get_new_target_obstacle()
	
	if target_obstacle:
		# If we reached an obstacle, start attacking
		attack_cooldown.start()
		$StateChart.send_event("Attack")
	else:
		# If we reached a path node, advance to next node
		path_target_index += 1
		if path_target_index >= path.get_child_count():
			for goal in get_tree().get_nodes_in_group("goal"):
				nav_agent.target_position = goal.global_position
				targeting_goal = true
		
		move_to_next_pathfinding_node()

# Find and target nearest obstacle within range
func get_new_target_obstacle():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		if obstacle.global_position.distance_to(global_position) < 32:
			target_obstacle = obstacle
			# Connect to obstacle's death signal
			if !target_obstacle.health_component.health_below_zero.is_connected(_target_obstacle_destroyed):
				target_obstacle.health_component.health_below_zero.connect(_target_obstacle_destroyed)
			#print("found nearby obstacle " + str(obstacle))
			# Move toward the obstacle
			nav_agent.target_position = target_obstacle.global_position
			
			#DEPRECATED
			#pathfinding.move_to(target_obstacle.global_position)

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
			
			#DEPRECATED
			#pathfinding.move_to(current_target_path_node.global_position)
			
			nav_agent.target_position = current_target_path_node.global_position
			
			$StateChart.send_event("NewPathFound")
		else:
			# Target the goal if the end of path was reached
			for goal in get_tree().get_nodes_in_group("goal"):
				nav_agent.target_position = goal.global_position
				targeting_goal = true


func drop_new_part():
	##generates a random number 0, 100. If the number is larger than the weight, then no part will drop
	var drop_weight = 100 / unit_data.count
	if randf_range(0, 100) > drop_weight: return
	print("Drop success")
	var new_part_drop : BodyPart
	
	var rarity : int = PartsManager.calculate_new_rarity(0)
	var type : int = PartsManager.calculate_new_type()
	
	if type == 0: new_part_drop = PartsManager.generate_new_head(rarity)
	if type == 1: new_part_drop = PartsManager.generate_new_body(rarity)
	if type == 2: new_part_drop = PartsManager.generate_new_legs(rarity)
	
	#can be used for ui and visuals to show a new drop has occured
	PartsManager.new_part_dropped.emit(new_part_drop)
	PartsManager.parts.append(new_part_drop)
	return

func _on_damage_taken(_damage_value):
	pass

func _on_death():
	print("Unit died!")
	check_if_final_unit()
	drop_new_part()
	LevelManager.update_points_total(50)
	queue_free()
