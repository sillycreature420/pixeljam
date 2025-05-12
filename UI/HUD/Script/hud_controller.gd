extends Control

# Reference to the playing phase UI element
@onready var playing_scene: Control = $Playing
# Reference to the preparation phase UI element
@onready var preparing_scene: Control = $Preparing

@onready var groups_container: GridContainer = $Preparing/VBoxContainer/GroupPathDialog/Groups
@onready var paths_container: GridContainer = $Preparing/VBoxContainer/GroupPathDialog/Paths



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to the LevelManager's signal for when a level transition completes
	LevelManager.transition_completed.connect(_level_transition_completed)
	
	# Initially hide both UI scenes
	playing_scene.hide()
	preparing_scene.hide()

# Handler for when a level transition is completed
func _level_transition_completed():
	# Show preparation UI and hide playing UI
	preparing_scene.show()
	playing_scene.hide()
	
	# TODO: Implement showing proper groups from Level GroupManagerComponent
	# This will need to be implemented to display the correct groups during preparation phase

# Handler for when the build button is pressed
func _on_build_button_pressed() -> void:
	# Get reference to and show the build scene
	var build_scene = $"../BuildScene"
	build_scene.show()
	
# Handler for when the play button is pressed
func _on_play_button_pressed() -> void:
	# Emit signal indicating preparation phase is done
	EventBus.emit_prep_phase_done()
	
	# Switch to playing phase UI
	preparing_scene.hide()
	playing_scene.show()

### DEBUG HUD FUNCTIONS ###
# Debug function to return to preparation phase
func _on_return_to_prep_button_pressed() -> void:
	# Show preparation UI and hide playing UI
	preparing_scene.show()
	playing_scene.hide()
