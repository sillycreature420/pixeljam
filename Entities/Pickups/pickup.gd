class_name Pickup extends Area2D

#TODO Extend pickup script
# - Should describe what the pickup is
# - Should add itself to a list of collected pickups once picked up
enum PickupType {BODY_PART, POINTS, ABILITY}

@export var type: PickupType

var picked_up = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("units"):
		if !picked_up:
			print("Got pickup!")
			if type == PickupType.POINTS:
				LevelManager.update_points_total(200)
			if type == PickupType.BODY_PART:
				var new_part = PartsManager.generate_new_body_part(PartsManager.calculate_new_type(), PartsManager.calculate_new_rarity(2))
				PartsManager.new_part_dropped.emit(new_part)
				PartsManager.parts.append(new_part)
			queue_free()
			picked_up = true
