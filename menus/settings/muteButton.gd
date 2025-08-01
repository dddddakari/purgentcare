
extends TextureButton

func _ready():
	# Connect to the global audio manager
	AudioManager.music_toggled.connect(_on_music_toggled)
	# Set initial texture
	texture_normal = AudioManager.get_speaker_texture()
	# Connect button press
	pressed.connect(_on_pressed)
	# Prevent space key from triggering button
	focus_mode = Control.FOCUS_NONE

func _on_pressed():
	AudioManager.toggle_music()

func _on_music_toggled(is_muted: bool):
	texture_normal = AudioManager.get_speaker_texture()
