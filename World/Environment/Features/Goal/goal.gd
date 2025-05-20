extends Node2D

@onready var health_component: HealthComponent = $HealthComponent

const WIN_MUSIC = preload("res://Assets/Audio/Music/pixeljam level music demo 2.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_component.health_below_zero.connect(_on_destroyed)
	$ProgressBar.min_value = 0
	$ProgressBar.max_value = health_component.max_health
	$ProgressBar.value = health_component.current_health

#TODO: Implement level completed logic
func _on_destroyed():
	$"/root/World/UILayer/WinScreen".show()
	$"/root/World/Music".stream = WIN_MUSIC
	$"/root/World/Music".play()
	LevelManager.level_won = true

func unit_reached_goal(damage_taken: float):
	EventBus.emit_points_added(1000)
	%GoalReached.play()
	health_component.damage(damage_taken)


func _on_health_component_damage_taken(amount_damage_taken: float) -> void:
	$ProgressBar.value = health_component.current_health
