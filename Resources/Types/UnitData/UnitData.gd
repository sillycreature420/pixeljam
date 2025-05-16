extends Resource
class_name UnitData

# Body part exports - these define the unit's appearance and stats
@export var head_part : BodyPart  # Head component affecting unit properties
@export var body_part : BodyPart  # Body component affecting unit properties  
@export var legs_part : BodyPart  # Legs component affecting movement properties

# Combat variables
var max_health: float  # Current health
var damage: float = 1.0  # Base damage output
var speed: float  # Movement speed
var count: float = 1

#TODO Populate this with the actual types of units we will have
enum CREATURE_TYPE{ZOMBIE}
@export var creature_type : CREATURE_TYPE

# Initialize unit with optional body parts
func _init(_head_part : BodyPart = null, _body_part : BodyPart = null, _legs_part : BodyPart = null) -> void:
	# Set body parts with fallback warnings
	if _head_part: 
		head_part = _head_part
	else: 
		push_warning("Initialized without headpart")
	
	if _body_part: 
		body_part = _body_part
	else: 
		push_warning("Initialized without bodypart")
	
	if _legs_part: 
		legs_part = _legs_part
	else: 
		push_warning("Initialized without legspart")
	
	initialize_unit_stats.call_deferred()
	return

func initialize_unit_stats():
	
	max_health = head_part.health_modifier + body_part.health_modifier + legs_part.health_modifier
	damage = head_part.damage_modifier + body_part.damage_modifier + legs_part.damage_modifier
	speed = head_part.speed_modifier + body_part.speed_modifier + legs_part.speed_modifier
	count = head_part.count_modifier + body_part.count_modifier + legs_part.count_modifier
	
	if max_health <= 0: max_health = 1
	
	var type = body_part.creature_type
	creature_type = type
	return
