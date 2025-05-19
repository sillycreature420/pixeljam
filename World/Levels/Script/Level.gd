extends Node2D

# Level configuration properties
@export var level_name: String                # Name identifier for this level
@export var level_data: LevelData             # Data asset containing level config and info
@export var paths: Array[Node2D]              # Array of currently available paths in this level

@export_group("Debug")
@export var test_parts: Array[BodyPart]

@onready var hud: Control = $"../UILayer/HUD"
@onready var music_player: AudioStreamPlayer = $"/root/World/Music"

const LEVEL_MUSIC = preload("res://Assets/Audio/Music/pixeljam level music demo 4-2.wav")

# Spawn point for units (initialized when level loads)
var spawn_point: Node2D

# Current round of the current level
var current_round: int = 1
# Current number of points the player has
var current_points: int = 500
var new_group_cost: int = 50

func _ready() -> void:
	# Connect to global event bus signals
	EventBus.prep_phase_done.connect(start_action_phase)
	EventBus.action_phase_done.connect(end_action_phase)
	EventBus.points_added.connect(_update_points_total)
	LevelManager.transition_completed.connect(_level_loaded)
	
	#HACK Load in some test parts to start the level with
	#PartsManager.parts = test_parts
	#PartsManager.selected_part = 0
	
	LevelManager.total_points = current_points

func start_action_phase():
	# Spawn units, the spawn_point handles the path assignment
	for group in GroupManager.groups:
		spawn_point.spawn_group(group)
	
	%RoundStart.play()

func end_action_phase():
	# Increment round by one
	current_round += 1
	
	for child in $Units.get_children():
		child.queue_free()
	
	# Update the HUD to reflect the current level's status
	build_groups_container()
	build_paths_container()
	hud.update_round_display(current_round)
	EventBus.current_round = current_round
	
# Callback when level transition completes
func _level_loaded():
	# Cache reference to spawn point for later use
	spawn_point = $SpawnPoint
	
	# Special initialization for first level
	if level_name == "Level One":
		# Create default unit group for new players
		var first_unit_group = UnitGroup.new()
		first_unit_group.unit_data = preload("res://Resources/Data/UnitData/ZombieUnitData/DebugZombieUnitData.tres")
		first_unit_group.unit_scene = preload("res://Entities/Units/ZombieUnit/zombie_unit.tscn")
		
		# Add to group manager's tracking system
		GroupManager._new_group_added(first_unit_group, "Zombie")
	
	# Update the HUD to reflect the current level's status
	build_groups_container()
	build_paths_container()
	hud.update_round_display(current_round)
	_update_points_total(current_points)
	
	music_player.stream = LEVEL_MUSIC
	music_player.play()
	

func _group_selected(group):
	GroupManager.currently_selected_group = group
	EventBus.emit_prep_phase_group_selected(group)
	print(str(group) + " selected")


func _path_selected(path):
	GroupManager.assign_path(GroupManager.currently_selected_group, path)
	EventBus.emit_prep_phase_path_selected(path)
	print(str(path) + " assigned to group " + str(GroupManager.currently_selected_group))


func build_groups_container():
	# Clear the current group buttons
	for child in hud.groups_container.get_children():
		child.queue_free()
	
	# Clear the path labels
	for child in hud.paths_label_container.get_children():
		child.queue_free()
	
	# Add buttons for each group found in the group manager component
	for group in GroupManager.groups:
		var new_group_button = Button.new()
		new_group_button.text = "Group " + str(GroupManager.groups.find(group) + 1)
		new_group_button.icon = group.unit_data.head_part.sprite
		new_group_button.pressed.connect(_group_selected.bind(group))
		
		hud.groups_container.add_child(new_group_button)
		group.path_label = build_path_label(group)
		
		

func build_path_label(_group : UnitGroup) -> Label:
	
	var new_path_label = Label.new()
	if _group.target_path: new_path_label.text = _group.target_path.name
	else: new_path_label.text = "Choose a path!"
	new_path_label.custom_minimum_size = Vector2(16,32)
	hud.paths_label_container.add_child(new_path_label)
	return new_path_label

func build_paths_container():
	# Clear the current path buttons
	for child in hud.paths_container.get_children():
		child.queue_free()
	
	# Add buttons for each path found in the paths property
	for path in paths:
		var new_path_button = Button.new()
		new_path_button.text = "Path " + str(paths.find(path) + 1)
		
		new_path_button.pressed.connect(_path_selected.bind(path))
		
		hud.paths_container.add_child(new_path_button)


func _update_points_total(points: int):
	hud.update_points_display(current_points)
	

func _on_hud_unit_group_purchased(type: String) -> void:
	if current_points >= new_group_cost:
		var new_group = UnitGroup.new()
		EventBus.emit_new_group_added(new_group, type)
		current_points -= new_group_cost
		new_group_cost += 50
		LevelManager.hud.group_cost_label.text = str(new_group_cost) + " Points" 
		_update_points_total(current_points)
	else:
		push_warning("Not enough points to purchase a new group of units!")


func _on_music_finished() -> void:
	music_player.play()
