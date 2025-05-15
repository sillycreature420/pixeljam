extends Control

#TODO: Create button to reset/clear assembly, putting parts back into the list

#TODO: Create parts shop
# - Should randomly populate from list of premade parts
# - Should be able to reroll the shop with a selection of different parts


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


func show_currently_selected_part():
	%CurrentPart.body_part_resource = PartsManager.parts[PartsManager.selected_part]
	%CurrentPart.sprite_node.texture = PartsManager.parts[PartsManager.selected_part].sprite


func _on_select_prev_part_pressed() -> void:
	# Select the previous part, unless at the start of the array, in which case,
	# select the last part in the array
	if PartsManager.parts.size() > 0:
		if PartsManager.selected_part > 0:
			PartsManager.selected_part -= 1
			show_currently_selected_part()
		else:
			PartsManager.selected_part = PartsManager.parts.size() - 1
			show_currently_selected_part()
	else:
		print("There are no parts left")

func _on_select_next_part_pressed() -> void:
	# Select the next part, unless at the end of the array, in which case, select
	# the first part in the array
	if PartsManager.parts.size() > 0:
		if PartsManager.selected_part < PartsManager.parts.size() - 1:
			PartsManager.selected_part += 1
			show_currently_selected_part()
		else:
			PartsManager.selected_part = 0
			show_currently_selected_part()
	else:
		print("There are no parts left")


func _on_object_slot_head_object_info_stored() -> void:
	%CurrentPart.position = Vector2(0, 0)


func _on_object_slot_body_object_info_stored() -> void:
	%CurrentPart.position = Vector2(0, 0)


func _on_object_slot_legs_object_info_stored() -> void:
	%CurrentPart.position = Vector2(0, 0)
