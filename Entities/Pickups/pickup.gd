class_name Pickup extends Area2D

#TODO Extend pickup script
# - Should describe what the pickup is
# - Should add itself to a list of collected pickups once picked up
enum PickupType {BODY_PART, POINTS, ABILITY}

var type: PickupType

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("units"):
		print("Got pickup!")
		queue_free()
