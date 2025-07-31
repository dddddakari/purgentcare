extends Node2D

@onready var audioStream = $"Player/Camera2D2/BGMusic"

func _ready():
	# Debug: Check if audioStream is found
	if audioStream == null:
		print("ERROR: audioStream not found! Check the node path.")
		return
	
	print("Kitchen audioStream found:", audioStream.name)
	
	# Connect to the global audio manager
	AudioManager.music_toggled.connect(_on_music_toggled)
	
	# Set initial state based on mute setting
	AudioManager.set_audio_stream_state(audioStream)

func _on_music_toggled(is_muted: bool):
	AudioManager.set_audio_stream_state(audioStream)
