extends Area2D

# Dialogue configuration
@export_file("*.json") var dialogue_file: String = "res://json/adminexit.json"
@export var dialogue_player_path: NodePath = "/root/AdminRoom/Dialogue"

var dialogue_player: Node = null

func _ready() -> void:
	dialogue_player = get_node_or_null(dialogue_player_path)
	if dialogue_player == null:
		push_error("DialoguePlayer not found at path: " + str(dialogue_player_path))
	else:
		if dialogue_player.has_signal("option_selected"):
			dialogue_player.connect("option_selected", Callable(self, "_on_option_selected"))
		if dialogue_player.has_signal("dialogue_finished"):
			dialogue_player.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player") or dialogue_player == null:
		return
	if FileAccess.file_exists(dialogue_file):
		dialogue_player.d_file = dialogue_file
		dialogue_player.start()

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
	print("DEBUG: Handling scene change...")
	print("DEBUG: Current path chosen: ", QuestManager.path_chosen)
	
	if QuestManager.path_chosen == "bad":
		print("DEBUG: Loading bad path scene")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_rooms_area/Room_AreaCabinetSpilled.tscn")
	elif QuestManager.path_chosen == "good":
		print("DEBUG: Loading good path scene")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_rooms_area/Room_AreaUnlocked.tscn")
	else:
		print("DEBUG: Loading default scene")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_rooms_area/Room_AreaUnlocked.tscn")

func _on_dialogue_finished():
	print("Dialogue finished.")
