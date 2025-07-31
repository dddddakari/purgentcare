extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	use_dialogue()

func use_dialogue():
	var dialogue = get_parent().get_node("/root/FinalBossRoom/Dialogue")
	var dialogue_file_path = "res://json/finalshowdown.json"


	if dialogue:
			if FileAccess.file_exists(dialogue_file_path):
				dialogue.d_file = dialogue_file_path 
				dialogue.start()                    
				print("Game Entering dialogue started.")
			else:
				push_error("Dialogue file not found: " + dialogue_file_path)

			print("Letter READ")
	
func check_ending():
	if GameState.bad_points > GameState.good_points:
		get_tree().change_scene_to_file("res://scenes/bad_ending.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/good_ending.tscn")
