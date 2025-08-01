extends Area2D

func _ready() -> void:
	pass

func _on_body_entered(body: CharacterBody2D) -> void:
	use_dialogue()
	
func use_dialogue():
	var dialogue = get_parent().get_node("/root/BHallwayArea/Dialogue")
	var dialogue_file_path = "res://json/bossroom.json"


	if dialogue:
			if FileAccess.file_exists(dialogue_file_path):
				dialogue.d_file = dialogue_file_path 
				dialogue.start()                    
				print("Game Entering dialogue started.")
			else:
				push_error("Dialogue file not found: " + dialogue_file_path)

			print("Letter READ")
