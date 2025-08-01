extends Area2D

@onready var interactable: Area2D = $interactable

var dialogue_system = null
var last_dialogue_id = ""

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	print("interacting")
	use_dialogue()
		
func use_dialogue():
	dialogue_system = get_parent().get_node("/root/Bathroom/Dialogue")
	var dialogue_file_path = "res://json/eww.json"

	if dialogue_system:
		if FileAccess.file_exists(dialogue_file_path):
			dialogue_system.d_file = dialogue_file_path 
			dialogue_system.start()
			print("Love dialogue started.")
			QuestManager.set_nurse_left() 
			
			# Start monitoring the dialogue system
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)
