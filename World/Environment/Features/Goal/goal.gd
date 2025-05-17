extends Node2D

@onready var health_component: HealthComponent = $HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_component.health_below_zero.connect(_on_destroyed)


#TODO: Implement level completed logic
func _on_destroyed():
	pass


func unit_reached_goal(damage_taken: float):
	EventBus.emit_points_added(1000)
	health_component.damage(damage_taken)
