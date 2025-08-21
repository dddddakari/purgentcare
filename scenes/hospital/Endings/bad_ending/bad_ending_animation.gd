
extends Node2D

# File path to the showdown dialogue
const DIALOGUE_FILE_PATH := "res://json/over.json"

func _ready():
	use_dialogue()

# Start the final showdown dialogue
func use_dialogue():
	var dialogue = get_node_or_null("/root/BadEndingAnimation/Dialogue")
	if not dialogue:
		push_error("Dialogue node not found in FinalBossRoom!")
		return
	
	if not FileAccess.file_exists(DIALOGUE_FILE_PATH):
		push_error("Dialogue file not found: " + DIALOGUE_FILE_PATH)
		return
	
	dialogue.d_file = DIALOGUE_FILE_PATH
	dialogue.connect("action_triggered", Callable(self, "_on_dialogue_action"))
	dialogue.start()
	print("Final showdown dialogue started.")
