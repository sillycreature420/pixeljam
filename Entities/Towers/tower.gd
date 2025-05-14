extends Node2D

# Configuration - damage dealt per attack
@export var damage: float

# State machine and cooldown timer references
@onready var state_chart: StateChart = $StateChart
@onready var attack_cooldown: Timer = $AttackCooldown

# Track units in attack range and the current target
var units_in_range: Array[Unit]  # List of units within detection range
var targeted_unit: Unit  # Currently focused unit for attacking


func _ready() -> void:
	# Initialize state machine properties
	state_chart.set_expression_property("unit_in_range", false)


func _physics_process(_delta: float) -> void:
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
	
	# Clean up units that moved out of range
	for i in units_in_range.size():
		var unit = units_in_range[i-1]
		if unit:
			if unit.global_position.distance_to(global_position) > 64:
				units_in_range.remove_at(i)
		else:
			units_in_range.remove_at(i)
	
	# If no units left in range, update state
	if units_in_range.size() == 0:
		state_chart.set_expression_property("unit_in_range", false)


func _on_attacking_state_processing(_delta: float) -> void:
	# Target the first unit in range
	targeted_unit = units_in_range[0]
	
	# Start cooldown timer if not already running
	if attack_cooldown.is_stopped():
		attack_cooldown.start()


# Cooldown finished - execute attack
func _on_attack_cooldown_timeout() -> void:
	
	if targeted_unit:
		# Deal damage to the targeted unit
		targeted_unit.health_component.damage(damage)
	else:
		# No valid target - return to idle state
		state_chart.set_expression_property("unit_in_range", false)
		attack_cooldown.stop()
