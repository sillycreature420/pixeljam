extends HSlider
##A slider designed to manipulate audio buses.

@export var print_debug : bool = false

#max_db shouldn't really go very high
@export var max_db : float = 10
#-60db is effectively muted
@export var min_db : float = -60
@export var audio_bus_to_change : String
var audio_index

func _ready() -> void:
	audio_index = AudioServer.get_bus_index(audio_bus_to_change)
	value_changed.connect(on_slider_change)
	
	if min_value >= 0: push_error(name + " must have a minimum value that goes into the negatives to allow for quieter sounds. Suggsted min_value is -6")
	on_slider_change(0)
	

func on_slider_change(_amount_changed : float = 0):
	
	set_volume_in_db(calculate_volume_with_slider())
	if print_debug: print(AudioServer.get_bus_volume_db(audio_index))
	return

func set_volume_in_db(new_volume_db : float):
	if new_volume_db > max_db: new_volume_db = max_db
	if new_volume_db < min_db: new_volume_db = min_db
	AudioServer.set_bus_volume_db(audio_index, new_volume_db)
	return

func calculate_volume_with_slider() -> float:
	var _new_db = max_db * value
	return _new_db
