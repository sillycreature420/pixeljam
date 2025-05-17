extends Node2D
class_name HealthComponent

@export var max_health: float
var current_health: float

signal health_below_zero
signal full_health_reached
signal damage_taken(amount_damage_taken : float)
signal heal_given(amount_heal_given : float)


func _ready() -> void:
	set_health_to_max_health()
	return


func set_max_health(new_max_health : float):
	max_health = new_max_health
	return


func set_health_to_max_health():
	current_health = max_health
	return


func damage(amount_damage_taken : float):
	
	current_health -= amount_damage_taken
	if current_health < 0: 
		health_below_zero.emit()
	
	damage_taken.emit(amount_damage_taken)
	_flash_red()
	return


func heal(amount_heal_given : float):
	
	current_health += amount_heal_given
	if current_health > max_health: current_health = max_health
	
	heal_given.emit(amount_heal_given)
	return


func _flash_red():
	# Create a new tween
	var tween = create_tween()
	
	# Store the original modulate color
	var original_color = modulate
	
	# Flash to red
	tween.tween_property(get_parent(), "modulate", Color.RED, 0.1)
	# Flash back to original color
	tween.tween_property(get_parent(), "modulate", original_color, 0.1)
