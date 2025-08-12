extends Node2D
const SettingsScene = preload("res://menus/settings/settings_menu.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Settings") or Input.is_action_just_pressed("ui_cancel"):
		print("Settings key pressed!")
		
		var existing_settings = get_tree().get_nodes_in_group("settings")
		
		if existing_settings.size() > 0:
			print("Closing settings menu...")
			close_settings()
		else:
			print("Creating settings menu...")
			var settings = SettingsScene.instantiate()
			settings.add_to_group("settings")  # ✅ Correct group for toggle
			get_tree().current_scene.add_child(settings)
			print("Settings menu created and added!")

func close_settings():
	for node in get_tree().get_nodes_in_group("settings"):
		node.queue_free()
