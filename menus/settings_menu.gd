extends Node2D

const SettingsScene = preload("res://menus/settings_menu.tscn")

func _ready() -> void:
	pass # You might not need this if you're not doing anything in ready

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Settings"):
		# Check if settings isn't already open
		if get_tree().get_nodes_in_group("settings").size() == 0:
			var _settings = SettingsScene.instantiate()
