extends Node2D
class_name HealthComponent

var max_health
var health

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
	health = max_health
	return


func damage(amount_damage_taken : float):
	
	health -= amount_damage_taken
	if health < 0: health_below_zero.emit(); #TODO decide what happens when health hits 0
	
	damage_taken.emit(amount_damage_taken)
	return


func heal(amount_heal_given : float):
	
	health += amount_heal_given
	if health > max_health: health = max_health
	
	heal_given.emit(amount_heal_given)
	return
