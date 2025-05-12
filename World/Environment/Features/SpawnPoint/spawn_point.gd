extends Node2D

# Reference to the container node where spawned units will be added as children
@export var unit_container: Node2D

# Reference to the location where units will spawn
@onready var spawn_location: Node2D = $SpawnLocation

# Spawns a group of units based on the provided UnitGroup configuration
# @param group: The UnitGroup resource containing spawn configuration and Unit stats
func spawn_group(group: UnitGroup):
	# Get the path this group of units should follow
	var target_path = group.target_path
	
	# Get the packed scene (unit entity) to spawn
	var unit_scene = group.unit_scene
	
	# Spawn the specified number of units
	for i in range(group.unit_count):
		# Create a new instance of the unit
		var new_unit = unit_scene.instantiate()
		
		# Configure the unit's pathfinding path
		new_unit.path = target_path
		
		# Position the unit at the spawn location
		new_unit.global_position = spawn_location.global_position
		
		# Add the unit to the game world by making it a child of unit_container
		unit_container.add_child(new_unit)
