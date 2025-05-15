extends Control
class_name HUD

signal unit_group_purchased(type: String)

# Reference to the playing phase UI element
@onready var playing_scene: Control = $Playing
# Reference to the preparation phase UI element
@onready var preparing_scene: Control = $Preparing

@onready var groups_container: GridContainer = $Preparing/VBoxContainer/GroupPathDialog/Groups
@onready var paths_container: GridContainer = $Preparing/VBoxContainer/GroupPathDialog/Paths

var group_type_to_purchase: String
var group_type_to_purchase_index: int
var ready_to_play: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to the LevelManager's signal for when a level transition completes
	LevelManager.transition_completed.connect(_level_transition_completed)
	EventBus.hud = self
	# Initially hide both UI scenes
	playing_scene.hide()
	preparing_scene.hide()
	
	group_type_to_purchase = UnitData.CREATURE_TYPE.keys()[group_type_to_purchase_index]


# Handler for when a level transition is completed
func _level_transition_completed():
	# Show preparation UI and hide playing UI
	preparing_scene.show()
	playing_scene.hide()


# Handler for when the build button is pressed
func _on_build_button_pressed() -> void:
	# Get reference to and show the build scene
	var build_scene = $"../BuildScene"
	build_scene.show()
	

# Handler for when the play button is pressed
func _on_play_button_pressed() -> void:
	#TODO Check that all groups have both a path selected and UnitData assigned
	# change ready_to_play to true if they do
	
	#if ready_to_play:
	# Emit signal indicating preparation phase is done
	EventBus.emit_prep_phase_done()
	
	# Switch to playing phase UI
	preparing_scene.hide()
	playing_scene.show()

func update_round_display(current_round: int):
	%CurrentRound.text = str(current_round)


func update_points_display(current_points: int):
	%CurrentPoints.text = str(current_points)

func purchase_group(type: String):
	unit_group_purchased.emit(type)


### DEBUG HUD FUNCTIONS ###
# Debug function to return to preparation phase
func _on_return_to_prep_button_pressed() -> void:
	EventBus.emit_action_phase_done()
	
	# Show preparation UI and hide playing UI
	preparing_scene.show()
	playing_scene.hide()


func _on_add_group_debug_button_pressed() -> void:
	%DebugGroupOptions.show()

func debug_new_group_type_selected(type: String):
	var new_group = UnitGroup.new()
	EventBus.emit_new_group_added(new_group, type)
	


func _on_buy_group_pressed() -> void:
	purchase_group(group_type_to_purchase)


func _on_type_to_buy_pressed() -> void:
	if group_type_to_purchase_index < UnitData.CREATURE_TYPE.keys().size()-1:
		group_type_to_purchase_index += 1
	else:
		group_type_to_purchase_index = 0
	group_type_to_purchase = UnitData.CREATURE_TYPE.keys()[group_type_to_purchase_index]
	%TypeToBuy.text = group_type_to_purchase
