extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	print("letter interacted")
	use_dialogue()
	
func use_dialogue():
	var dialogue = get_parent().get_node("/root/Kitchen01/Dialogue")
	var dialogue_file_path = "res://json/letter.json"


	if dialogue:
		if FileAccess.file_exists(dialogue_file_path):
			dialogue.d_file = dialogue_file_path
			dialogue.start()
			print("Letter dialogue started.")
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)

		print("Letter READ")
