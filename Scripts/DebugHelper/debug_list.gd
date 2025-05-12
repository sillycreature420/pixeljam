extends RichTextLabel
class_name DebugLabel
##Put the node you wish to display the variables of into the key, then in the value, create and array
##and type in the variables you wish to display.
##This will update every frame at runtime.

@export var show_debug : bool = true
@export var list_of_nodes : Dictionary[Node,Array]


func _ready() -> void:
	print("debug here")
	if !show_debug:
		queue_free()

func _process(_delta : float) -> void:
	update_text()
	return

func update_text():
	text = ""
	
	for index in list_of_nodes:
		var property_array = list_of_nodes[index]
		add_text(index.name + "\n")
		for property in property_array:
			assert(property is String, "The value " + str(property) + " in the array must be a string to display the variable.")
			add_text(property +  ": " + str(index[property]) + ("\n"))
		add_text("\n")
	return
