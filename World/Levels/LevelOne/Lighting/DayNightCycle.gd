extends DirectionalLight2D

@export var day_time_energy : float = 5
@export var night_time_energy : float = 15
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.prep_phase_done.connect(night_time)
	EventBus.action_phase_done.connect(day_time)
	pass # Replace with function body.

func day_time():
	energy = day_time_energy
	return

func night_time():
	energy = night_time_energy
	return
