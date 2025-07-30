extends Node2D

@onready var audioStream = $"BGMusic"

func _ready():
	# Connect to the global audio manager
	AudioManager.music_toggled.connect(_on_music_toggled)
	# Apply current mute state
	audioStream.stream_paused = AudioManager.is_music_muted

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/kitchen/kitchen01.tscn")
	print("new game started")

func _on_continue_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_music_toggled(is_muted: bool):
	audioStream.stream_paused = is_muted
