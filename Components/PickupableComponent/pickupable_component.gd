extends Area2D
class_name PickupableComponent

signal picked_up
signal placed_down

var held : bool = false
var node_to_pickup : Node2D

func _ready() -> void:
	node_to_pickup = get_parent()
	return

func _process(delta: float) -> void:
	if held: object_to_mouse()
	return

func object_to_mouse():
	node_to_pickup.global_position = get_global_mouse_position()
	if node_to_pickup is RigidBody2D: node_to_pickup.gravity_scale = 0; node_to_pickup.linear_velocity = Vector2.ZERO
	check_for_release()
	return


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	check_for_grab(event)
	
	return

func check_for_grab(_event : InputEvent):
	if _event is InputEventMouseMotion && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !EventBus.current_object_held:
		held = true
		EventBus.current_object_held = self
		picked_up.emit()
	return

func check_for_release():
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && EventBus.current_object_held == self:
		EventBus.current_object_held = null
		held = false
		placed_down.emit()
		#if node_to_pickup is RigidBody2D: node_to_pickup.gravity_scale = 1
	return
