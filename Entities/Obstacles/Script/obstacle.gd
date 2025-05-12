extends Node2D

#TODO Add points when obstacle destroyed
@export var health_component: HealthComponent

func _ready() -> void:
	health_component.damage_taken.connect(_on_damage_taken)
	print(health_component)

func _on_damage_taken(_amount_damage_taken):
	_flash_red()

func _flash_red():
	# Create a new tween
	var tween = create_tween()
	
	# Store the original modulate color
	var original_color = modulate
	
	# Flash to red
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	# Flash back to original color
	tween.tween_property(self, "modulate", original_color, 0.1)
