extends Node2D

@onready var audioStream = $"CharacterBody2D/BGMusic" 
var entered = false


func _ready():
	# Only connect if audioStream exists in this scene
	if audioStream != null:
		AudioManager.music_toggled.connect(_on_music_toggled)
		AudioManager.set_audio_stream_state(audioStream)
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D": 
		get_tree().change_scene_to_file.call_deferred("res://minigames/maze/Jumpscare.tscn")


func _on_exit_body_entered(_body: Node2D) -> void:
	if _body.name == "CharacterBody2D":
		get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/f1_rooms_area/Room_AreaLocked.tscn")

func _on_music_toggled(_is_muted: bool):
	if audioStream != null:
		AudioManager.set_audio_stream_state(audioStream)



	
