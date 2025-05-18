extends RichTextLabel

@export var object_slot_1 : Object_Slot
@export var object_slot_2 : Object_Slot
@export var object_slot_3 : Object_Slot

func _ready() -> void:
	
	object_slot_1.object_info_stored.connect(update_stats_text)
	object_slot_2.object_info_stored.connect(update_stats_text)
	object_slot_3.object_info_stored.connect(update_stats_text)
	
	return

func update_stats_text():
	
	var health_modifier  = 0
	var damage_modifier = 0
	var speed_modifier = 0
	var count_modifier = 0
	var attack_speed_modifier = 0
	
	if object_slot_1.object_held:
		health_modifier += object_slot_1.object_held.health_modifier
		damage_modifier += object_slot_1.object_held.damage_modifier
		speed_modifier += object_slot_1.object_held.speed_modifier
		count_modifier += object_slot_1.object_held.count_modifier
		attack_speed_modifier += object_slot_1.object_held.attack_speed_modifier
	
	if object_slot_2.object_held:
		health_modifier += object_slot_2.object_held.health_modifier
		damage_modifier += object_slot_2.object_held.damage_modifier
		speed_modifier += object_slot_2.object_held.speed_modifier
		count_modifier += object_slot_2.object_held.count_modifier
		attack_speed_modifier += object_slot_2.object_held.attack_speed_modifier
	
	if object_slot_3.object_held:
		health_modifier += object_slot_3.object_held.health_modifier
		damage_modifier += object_slot_3.object_held.damage_modifier
		speed_modifier += object_slot_3.object_held.speed_modifier
		count_modifier += object_slot_3.object_held.count_modifier
		attack_speed_modifier += object_slot_3.object_held.attack_speed_modifier
		
	
	if health_modifier <= 0: health_modifier = 1
	if damage_modifier <= 0: damage_modifier = 1
	if speed_modifier <= 0: speed_modifier = 1
	if count_modifier <= 0: count_modifier = 1
	if attack_speed_modifier <= 0: attack_speed_modifier = 1
	
	text = ""
	
	text += "\nHealth: " + str(health_modifier)
	text += "\nDamage: " + str(damage_modifier)
	text += "\nSpeed: " + str(speed_modifier)
	text += "\nCount: " + str(count_modifier)
	text += "\nAttack Speed: " + str(attack_speed_modifier)
	
	return
