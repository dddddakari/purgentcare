extends Node2D

@onready var audioStream = $"Player/Camera2D2/BGMusic"

func _ready():
	use_dialogue()
	# Debug: Check if audioStream is found
	if audioStream == null:
		print("ERROR: audioStream not found! Check the node path.")
		return
	
	print("Kitchen audioStream found:", audioStream.name)
	
	# Connect to the global audio manager
	AudioManager.music_toggled.connect(_on_music_toggled)
	
	# Set initial state based on mute setting
	AudioManager.set_audio_stream_state(audioStream)
	
func use_dialogue():
	var dialogue = get_parent().get_node("/root/Kitchen01/Dialogue")
	var dialogue_file_path = "res://json/op_dialogue.json"


	if dialogue:
			if FileAccess.file_exists(dialogue_file_path):
				dialogue.d_file = dialogue_file_path 
				dialogue.start()                    
				print("Game Entering dialogue started.")
			else:
				push_error("Dialogue file not found: " + dialogue_file_path)

			print("Letter READ")


func _on_music_toggled(is_muted: bool):
	AudioManager.set_audio_stream_state(audioStream)
