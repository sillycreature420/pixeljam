extends Node2D

# Configuration - damage dealt per attack
@export var damage: float
@export var projectile_scene: PackedScene

# State machine and cooldown timer references
@onready var state_chart: StateChart = $StateChart
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var projectiles: Node2D = $Projectiles

# Track units in attack range and the current target
var units_in_range: Array[Unit]  # List of units within detection range
var targeted_unit: Unit  # Currently focused unit for attacking
var target_last_position: Vector2

func _ready() -> void:
	# Initialize state machine properties
	state_chart.set_expression_property("unit_in_range", false)


func _physics_process(delta: float) -> void:
	# Unit detection and tracking logic
	
	# Check all units in the "units" group for proximity
	for unit in get_tree().get_nodes_in_group("units"):
		# If unit is within 64 units distance
		if unit.global_position.distance_to(global_position) < 64:
			# Update state machine and trigger alert
			state_chart.set_expression_property("unit_in_range", true)
			state_chart.send_event("Alert")
			
			# Add new units to tracking list
			if !units_in_range.has(unit):
				units_in_range.append(unit)
				if !unit.health_component.health_below_zero.is_connected(_unit_killed):
					unit.health_component.health_below_zero.connect(_unit_killed.bind(unit))
	
	# Clean up units that moved out of range
	if units_in_range.size() > 0:
		for i in units_in_range.size():
			var unit_index = i - 1
			var unit = units_in_range[unit_index]
			if unit:
				if unit.global_position.distance_to(global_position) > 64:
					units_in_range.remove_at(i)
			else:
				if i < units_in_range.size():
					units_in_range.remove_at(i)
				
	# If no units left in range, update state
	if units_in_range.size() == 0:
		state_chart.set_expression_property("unit_in_range", false)
	
	if targeted_unit:
		target_last_position = targeted_unit.global_position
		for projectile in projectiles.get_children():
			projectile.update_position(targeted_unit.global_position, delta)
	else:
		for projectile in projectiles.get_children():
			projectile.update_position(target_last_position, delta)


func _on_attacking_state_processing(_delta: float) -> void:
	# Target the first unit in range
	targeted_unit = units_in_range[0]
	
	# Start cooldown timer if not already running
	if attack_cooldown.is_stopped():
		attack_cooldown.start()


# Cooldown finished - execute attack
func _on_attack_cooldown_timeout() -> void:
	
	if targeted_unit:
		# Fire a projectile
		var new_projectile = projectile_scene.instantiate()
		new_projectile.damage = damage
		new_projectile.target_unit = targeted_unit
		projectiles.add_child(new_projectile)
		
	else:
		# No valid target - return to idle state
		state_chart.set_expression_property("unit_in_range", false)
		attack_cooldown.stop()


func _unit_killed(unit):
	units_in_range.erase(unit)
	state_chart.send_event("UnitKilled")
	if unit.health_component.health_below_zero.is_connected(_unit_killed):
		unit.health_component.health_below_zero.disconnect(_unit_killed)
