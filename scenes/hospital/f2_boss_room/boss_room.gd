extends Node2D

# Called when the node enters the scene tree for the first time
var dialogue_player: Node = null

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

func _on_option_selected(option_index: int) -> void:
	if dialogue_player == null:
		return

	var current = dialogue_player.get_current_dialogue()
	if current == null:
		return

	var options = current.get("options", [])
	if option_index < 0 or option_index >= options.size():
		return

	var selected_option = options[option_index]
	if not selected_option.has("next_id"):
		return

	var next_id = selected_option["next_id"]
	print("DEBUG: Selected option leads to next_id: ", next_id)
	
	var next_dialogue = null
	for dialogue in dialogue_player.dialogue_data:
		if dialogue.get("id", "") == next_id:
			next_dialogue = dialogue
			break

	if next_dialogue == null:
		print("DEBUG: Could not find dialogue for next_id: ", next_id)
		return

	print("DEBUG: Found next dialogue: ", next_dialogue)
	
	# Check if this dialogue has a conditional scene change action
	if next_dialogue.has("action") and next_dialogue["action"] == "conditional_scene_change":
		print("DEBUG: Conditional scene change triggered!")
		# Show the leaving text first, then change scene
		if dialogue_player.has_method("goto_id"):
			dialogue_player.goto_id(next_id)
		# Use a timer to delay the scene change so the text shows
		await get_tree().create_timer(1.0).timeout
		_handle_scene_change()
		return
	# Continue normal dialogue flow if no scene change
	if dialogue_player.has_method("goto_id"):
		dialogue_player.goto_id(next_id)

func _handle_scene_change():
	if GameState.bad_points > GameState.good_points:
		get_tree().change_scene_to_file("res://scenes/hospital/Endings/bad_ending/bad_ending.tscn")
	elif GameState.bad_points == GameState.good_points:
		get_tree().change_scene_to_file("res://scenes/hospital/Endings/good_ending/good_ending.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/hospital/Endings/good_ending/good_ending.tscn")
		
func _on_dialogue_finished():
	print("Dialogue finished.")
