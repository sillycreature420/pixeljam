extends Node2D
class_name Unit

@export var head_part : BodyPart
@export var body_part : BodyPart
@export var legs_part : BodyPart

@export var path: Node2D

@onready var health_component : HealthComponent = $%HealthComponent
@onready var pathfinding: PathfindingComponent = $PathfindingComponent

var current_target_path_node: Node2D

func _init(_head_part : BodyPart = null, _body_part : BodyPart = null, _legs_part : BodyPart = null) -> void:
	
	if _head_part: head_part = _head_part
	else: push_warning("Initialized without headpart")
	if _body_part: body_part = _body_part
	else: push_warning("Initialized without bodypart")
	if _legs_part: legs_part = _legs_part
	else: push_warning("Initialized without legspart")

	call_deferred("initialize_components")
	return

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_spawn"):
		pathfinding.move_to(current_target_path_node.global_position)

func initialize_components():
	health_component.max_health = head_part.health_modifier + body_part.health_modifier + legs_part.health_modifier
	return

func _ready():
	current_target_path_node = path.get_child(0)
	pass
