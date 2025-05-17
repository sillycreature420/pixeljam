extends Resource
class_name BodyPart

@export_group("Graphics")
@export var name : String
@export var sprite : Texture2D
@export var display_priority : int = 0
#TODO Populate this with the actual types of units we will have
enum CREATURE_TYPE{ZOMBIE}
@export var creature_type : CREATURE_TYPE

@export_group("Stats")
@export var health_modifier : float = 1
@export var speed_modifier : float = 1
@export var count_modifier : int = 1
@export var damage_modifier : float = 1
@export var attack_speed_modifier : float = 1

@export_group("Typing")
enum RARITY{COMMON, UNCOMMON, RARE}
@export var rarity : RARITY

enum BODY_TYPE{HEAD, BODY, LEGS}
@export var body_type: BODY_TYPE
