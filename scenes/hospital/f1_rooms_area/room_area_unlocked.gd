extends Node2D

@onready var audioStream = $"Player/Camera2D2/BGMusic"

func _ready():
	if QuestManager.nurse_left_to_find_janitor:
		print("DEBUG: Nurse has left, hiding/removing nurse")
		if has_node("Nurse"):
			$Nurse.queue_free()
		
		# Check if keycard already exists in the scene
		var keycard = get_tree().get_first_node_in_group("keycard")
		if not keycard and not QuestManager.has_quest_item("nurse_keycard"):
			# If no keycard exists and player doesn't have it, spawn one
			var keycard_scene = preload("res://entities/items/keycard/keycard.tscn")
			keycard = keycard_scene.instantiate()
			# Position it where the nurse was (or a default position)
			var nurse_pos = Vector2(500, 300)  # Adjust this to your nurse's typical position
			keycard.position = nurse_pos + Vector2(20, 20)
			add_child(keycard)
			print("Respawning keycard at position: ", keycard.position)
	
	# Rest of your existing _ready() code...
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
