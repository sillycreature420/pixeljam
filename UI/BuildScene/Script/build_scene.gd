extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _on_ready_button_pressed() -> void:
	hide()


func build_groups_container():
	# Clear the current group buttons
	for child in %Groups.get_children():
		child.queue_free()
	
	# Add buttons for each group found in the group manager component
	for group in GroupManager.groups:
		var new_group_button = Button.new()
		new_group_button.text = "Group " + str(GroupManager.groups.find(group) + 1)
		
		new_group_button.pressed.connect(_group_selected.bind(group))
		
		%Groups.add_child(new_group_button)


func _group_selected(group):
	GroupManager.currently_selected_group = group
	print(str(group) + " selected")


func _on_visibility_changed() -> void:
		if visible:
			build_groups_container()
