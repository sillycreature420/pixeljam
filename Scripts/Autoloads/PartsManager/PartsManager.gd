extends Node

var parts: Array[BodyPart]

signal no_more_parts
signal new_part_dropped(new_part : BodyPart)
# Index of the currently selected part
var selected_part: int = 0
var last_type_dropped : int = 3


var head_resource_parts = DirAccess.get_files_at("res://Resources/Data/BodyPart/HeadParts/")
var head_resource_parts_common = DirAccess.get_files_at("res://Resources/Data/BodyPart/HeadParts/Parts/Common/")
var head_resource_parts_uncommon = DirAccess.get_files_at("res://Resources/Data/BodyPart/HeadParts/Parts/Uncommon/")
var head_resource_parts_rare = DirAccess.get_files_at("res://Resources/Data/BodyPart/HeadParts/Parts/Rare/")

var body_resource_parts = DirAccess.get_files_at("res://Resources/Data/BodyPart/BodyParts/")
var body_resource_parts_common = DirAccess.get_files_at("res://Resources/Data/BodyPart/BodyParts/Parts/Common/")
var body_resource_parts_uncommon = DirAccess.get_files_at("res://Resources/Data/BodyPart/BodyParts/Parts/Uncommon/")
var body_resource_parts_rare = DirAccess.get_files_at("res://Resources/Data/BodyPart/BodyParts/Parts/Rare/")

var legs_resource_parts = DirAccess.get_files_at("res://Resources/Data/BodyPart/LegParts/")
var legs_resource_parts_common = DirAccess.get_files_at("res://Resources/Data/BodyPart/LegParts/Parts/Common/")
var legs_resource_parts_uncommon = DirAccess.get_files_at("res://Resources/Data/BodyPart/LegParts/Parts/Uncommon/")
var legs_resource_parts_rare = DirAccess.get_files_at("res://Resources/Data/BodyPart/LegParts/Parts/Rare/")

func calculate_new_type() -> int:
	var new_type
	var head_weight = 33
	var body_weight = 33
	var legs_weight = 33
	
	##If a type has previously been dropped/seen in the shop, then reduce the chance you see that type
	##this way you're more likely to get parts you need
	#TODO upgrade this to take into account more than just the previous drop
	if last_type_dropped == 0: head_weight -= 20
	elif last_type_dropped == 1: body_weight -= 20
	elif last_type_dropped == 2: legs_weight -= 20
	
	var max_range = head_weight + body_weight + legs_weight
	var random_number = randi_range(0, max_range)
	
	#0 -> head_weight = head
	if 0 <= random_number && random_number <= head_weight: new_type = 0
	
	#if the random number is between head_weight and body_weight + head_weight then output body_type
	elif head_weight < random_number && random_number <= body_weight + head_weight: new_type = 1
	
	#at this point this is guarenteed but putting it in so if something is wrong it'll crash
	elif body_weight + head_weight < random_number && random_number <= legs_weight + body_weight + head_weight: new_type = 2
	
	last_type_dropped = new_type
	print("New type created: " + str(new_type))
	return new_type

func calculate_new_rarity(round_modifier : int) -> int:
	var new_rarity : int
	var current_round = EventBus.current_round + round_modifier + 1
	print("The round is: " + str(current_round))
	#y = (a * current_round)^2 - (b * current_round) + c
	var common_weight:float = (45.0/88.0 * current_round)** 2 - (685.0/44.0 * current_round) + 9245.0/88.0
	var uncommon_weight: float = (-10/9.0 * current_round)** 2 + (50.0/3.0 * current_round) - 50.0/9.0
	var rare_weight:float = (6111.0/10000.0 * current_round) ** 2 - (11667.0/100000.0 * current_round) + 1389.0/2500.0
	
	if current_round >= 10: common_weight = 0
	if current_round >= 5: uncommon_weight = 50
	if current_round >= 10: rare_weight = 50
	
	var max_range = common_weight + uncommon_weight + rare_weight
	var random_number = randi_range(0, max_range)
	
	if 0 <= random_number && random_number <= common_weight: new_rarity = 0
	elif common_weight < random_number && random_number <= uncommon_weight + common_weight: new_rarity = 1
	elif uncommon_weight + common_weight < random_number && random_number <= rare_weight + uncommon_weight + common_weight: new_rarity = 2
	
	print("New rarity created: " + str(new_rarity))
	return new_rarity

func generate_new_head(rarity : int) -> BodyPart:
	var new_part : BodyPart
	rarity = clamp(rarity, 0, 2)
	
	if rarity == 0:
		var new_resource = head_resource_parts_common[randi() % head_resource_parts_common.size()]
		new_part = load("res://Resources/Data/BodyPart/HeadParts/Parts/Common/" + new_resource)
		
	elif rarity == 1:
		var new_resource = head_resource_parts_uncommon[randi() % head_resource_parts_uncommon.size()]
		new_part = load("res://Resources/Data/BodyPart/HeadParts/Parts/Uncommon/" + new_resource)
		
	elif rarity == 2:
		var new_resource = head_resource_parts_rare[randi() % head_resource_parts_rare.size()]
		new_part = load("res://Resources/Data/BodyPart/HeadParts/Parts/Rare/" + new_resource)
		
	else: push_error("Rarity was not within the expected range of 0 to 2.")
	
	assert(new_part.rarity == rarity, new_part.resource_path + " has a mismatched rarity, this part has rarity: " + str(new_part.rarity) + " while it is in the folder of rarity: " + str(rarity))
	return new_part

func generate_new_body(rarity : int) -> BodyPart:
	var new_part : BodyPart
	rarity = clamp(rarity, 0, 2)
	
	if rarity == 0:
		var new_resource = body_resource_parts_common[randi() % body_resource_parts_common.size()]
		new_part = load("res://Resources/Data/BodyPart/BodyParts/Parts/Common/" + new_resource)
		
	elif rarity == 1:
		var new_resource = body_resource_parts_uncommon[randi() % body_resource_parts_uncommon.size()]
		new_part = load("res://Resources/Data/BodyPart/BodyParts/Parts/Uncommon/" + new_resource)
		
	elif rarity == 2:
		var new_resource = body_resource_parts_rare[randi() % body_resource_parts_rare.size()]
		new_part = load("res://Resources/Data/BodyPart/BodyParts/Parts/Rare/" + new_resource)
		
	else: push_error("Rarity was not within the expected range of 0 to 2.")
	
	assert(new_part.rarity == rarity, new_part.resource_path + " has a mismatched rarity, this part has rarity: " + str(new_part.rarity) + " while it is in the folder of rarity: " + str(rarity))
	return new_part

func generate_new_legs(rarity : int) -> BodyPart:
	var new_part : BodyPart
	rarity = clamp(rarity, 0, 2)
	
	if rarity == 0:
		var new_resource = legs_resource_parts_common[randi() % legs_resource_parts_common.size()]
		new_part = load("res://Resources/Data/BodyPart/LegParts/Parts/Common/" + new_resource)
		
	elif rarity == 1:
		var new_resource = legs_resource_parts_uncommon[randi() % legs_resource_parts_uncommon.size()]
		new_part = load("res://Resources/Data/BodyPart/LegParts/Parts/Uncommon/" + new_resource)
		
	elif rarity == 2:
		var new_resource = legs_resource_parts_rare[randi() % legs_resource_parts_rare.size()]
		new_part = load("res://Resources/Data/BodyPart/LegParts/Parts/Rare/" + new_resource)
		
	else: push_error("Rarity was not within the expected range of 0 to 2.")
	
	assert(new_part.rarity == rarity, new_part.resource_path + " has a mismatched rarity, this part has rarity: " + str(new_part.rarity) + " while it is in the folder of rarity: " + str(rarity))
	return new_part
