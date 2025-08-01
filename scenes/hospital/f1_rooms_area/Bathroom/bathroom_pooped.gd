extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	use_dialogue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func use_dialogue():
	var dialogue = get_parent().get_node("/root/Bathroom/Dialogue")
	var dialogue_file_path = "res://json/janitorangry.json"

	if dialogue:
			if FileAccess.file_exists(dialogue_file_path):
				dialogue.d_file = dialogue_file_path 
				dialogue.start()                    
				print("Game Entering dialogue started.")
			else:
				push_error("Dialogue file not found: " + dialogue_file_path)

			print("Letter READ")
