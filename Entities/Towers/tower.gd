extends Node2D

@export var damage: float

@onready var state_chart: StateChart = $StateChart
@onready var attack_cooldown: Timer = $AttackCooldown

var units_in_range: Array[Unit]
var targeted_unit: Unit

func _ready() -> void:
	state_chart.set_expression_property("unit_in_range", false)


func _physics_process(_delta: float) -> void:
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.global_position.distance_to(global_position) < 64:
			state_chart.set_expression_property("unit_in_range", true)
			state_chart.send_event("Alert")
			if !units_in_range.has(unit):
				units_in_range.append(unit)
	
	for i in units_in_range.size():
		var unit = units_in_range[i-1]
		if unit.global_position.distance_to(global_position) > 64:
			units_in_range.remove_at(i)
			
	if units_in_range.size() == 0:
		state_chart.set_expression_property("unit_in_range", false)


func _on_attacking_state_processing(_delta: float) -> void:
	targeted_unit = units_in_range[0]
	if attack_cooldown.is_stopped():
		attack_cooldown.start()


func _on_attack_cooldown_timeout() -> void:
	if targeted_unit:
		targeted_unit.health_component.damage(damage)
	else:
		state_chart.set_expression_property("unit_in_range", false)
		attack_cooldown.stop()
