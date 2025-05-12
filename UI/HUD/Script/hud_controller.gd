extends Control

@onready var playing_scene: Control = $Playing
@onready var preparing_scene: Control = $Preparing


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.transition_completed.connect(_level_transition_completed)
	playing_scene.hide()
	preparing_scene.hide()


func _level_transition_completed():
	preparing_scene.show()
	playing_scene.hide()


func _on_build_button_pressed() -> void:
	var build_scene = $"../BuildScene"
	build_scene.show()
	
func _on_play_button_pressed() -> void:
	EventBus.prep_phase_done.emit()
	preparing_scene.hide()
	playing_scene.show()

### DEBUG HUD FUNCTIONS ###
func _on_return_to_prep_button_pressed() -> void:
	preparing_scene.show()
	playing_scene.hide()
