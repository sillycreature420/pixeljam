extends Resource
class_name BodyPart

@export_group("Graphics")
@export var sprite : Texture2D
@export var display_priority : int = 0
#TODO Populate these with the actual types of units we will have
enum CREATURE_TYPE{ZOMBIE, SKELETON, GHOST}
@export var creature_type : CREATURE_TYPE

@export_group("Stats")
@export var health_modifier : float = 1
@export var speed_modifier : float = 1
@export var count_modifier : int = 1
@export var damage_modifier : int = 1

@export_group("Typing")
enum RARITY{COMMON, UNCOMMON, RARE}
@export var rarity : RARITY

enum BODY_TYPE{HEAD, BODY, LEGS}
@export var body_type: BODY_TYPE
