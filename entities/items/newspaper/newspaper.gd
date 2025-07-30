# newspaper.gd
extends Area2D

# Node references
@onready var interactable: Area2D = $interactable  # Interaction trigger
@onready var sprite_2d: Sprite2D = $Sprite2D  # Visual representation

func _ready() -> void:
	# Set up interaction callback
	interactable.interact = _on_interact
	
func _on_interact():
	print("newspaper interacted")
	use_dialogue()  # Trigger dialogue when interacted
	
func use_dialogue():
	# Find and start newspaper dialogue

	var dialogue = get_parent().get_node("/root/Kitchen01/Dialogue")

	var dialogue_file_path = "res://json/newspaper.json"

	if dialogue:
		if FileAccess.file_exists(dialogue_file_path):
			# Set dialogue file and start
			dialogue.d_file = dialogue_file_path 
			dialogue.start()                    
			print("Newspaper dialogue started.")
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)

		print("nEWSPAPER READ")
