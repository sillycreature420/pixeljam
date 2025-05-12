extends RigidBody2D

@export var body_part_resource : BodyPart

var body_type
@onready var sprite_node : Sprite2D = $%ObjectSprite


func _ready() -> void:
	initialize_object()
	
	
	return

func initialize_object():
	sprite_node.texture = body_part_resource.sprite
	body_type = body_part_resource.body_type
	print(body_type)
	return
