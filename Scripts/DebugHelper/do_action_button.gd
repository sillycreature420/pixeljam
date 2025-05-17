extends Button
##Mainly used for quick testing

@export var node_to_do_action : Node
@export var method : String

func _ready():
	if node_to_do_action == null: return
	
	assert(node_to_do_action.has_method(method), name + " does not have the method " + method + ".")
	pressed.connect(on_pressed)
	return

func on_pressed():
	node_to_do_action.call(method)
	return
