extends Node2D

@onready var health_component: HealthComponent = $HealthComponent

const WIN_MUSIC = preload("res://Assets/Audio/Music/pixeljam level music demo 2.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_component.health_below_zero.connect(_on_destroyed)


#TODO: Implement level completed logic
func _on_destroyed():
	$"/root/World/UILayer/WinScreen".show()
	$"/root/World/Music".stream = WIN_MUSIC
	$"/root/World/Music".play()


func unit_reached_goal(damage_taken: float):
	EventBus.emit_points_added(1000)
	%GoalReached.play()
	health_component.damage(damage_taken)
