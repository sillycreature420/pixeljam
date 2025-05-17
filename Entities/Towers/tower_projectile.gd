extends Node2D

var projectile_speed: float = 80.0
var damage: float
var target_unit: Node2D

func update_position(target_global_pos: Vector2, delta: float) -> void:
	global_position = global_position.move_toward(
		target_global_pos, 
		projectile_speed * delta
		)
	if global_position == target_global_pos:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area == target_unit:
		area.health_component.damage(damage)
		queue_free()
