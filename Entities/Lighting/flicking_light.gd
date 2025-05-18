extends PointLight2D
class_name FlickingLight2D
##A flicking light for things that flicker, such as lanterns or torches.


@onready var timer : Timer = Timer.new()

##A multiplier for the intensity of the light, this is randomised in [method change_light_energy]
@export_range(0, 3, 0.1) var light_intensity : float = 1
##A multiplier for how long to wait between each intensity change
@export_range(0, 3, 0.1) var wait_time_variation : float = 1
##How fast the light switches to it's new value, shorter values produce snappier light changes, higher values
##produce smoother light changes
@export_range(0, 3, 0.1) var light_tween_speed : float = 1

func _ready() -> void:
	setup_timer()
	EventBus.prep_phase_done.connect(night_time)
	EventBus.action_phase_done.connect(day_time)
	day_time()
	return

func setup_timer():
	timer.autostart = false
	add_child(timer)
	timer.timeout.connect(change_light_energy)
	return

func change_light_energy():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "energy", randf() * light_intensity, light_tween_speed)
	timer.wait_time = randf_range(1 * wait_time_variation, 1.5 * wait_time_variation)
	return

func day_time():
	energy = 0
	timer.stop()
	return

func night_time():
	timer.start()
	return
