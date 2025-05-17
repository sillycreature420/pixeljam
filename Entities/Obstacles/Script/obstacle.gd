extends Node2D

# The value of this obstacle in points, awarded when it is destroyed
@export var point_value: int = 500

# This obstacle's health component
@export var health_component: HealthComponent

func _ready() -> void:
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.health_below_zero.connect(_on_destroyed)
	#print(health_component)


#TODO: When health reaches a certain threshold, change to the broken gate sprite
func _on_damage_taken(_amount_damage_taken):
	pass

func _on_destroyed():
	EventBus.emit_points_added(point_value)
	queue_free()
