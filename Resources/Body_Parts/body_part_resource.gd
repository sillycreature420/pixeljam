extends Resource
class_name BodyPart

@export var sprite : Texture2D
@export var priority : int = 0

@export var health_modifier : float = 1
@export var speed_modifier : float = 1
@export var count_modifier : int = 1

enum RARITY{COMMON, UNCOMMON, RARE}
@export var rarity : RARITY

enum BODY_TYPE{HEAD, BODY, LEGS}
@export var Body_type: BODY_TYPE
