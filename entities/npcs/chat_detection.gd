extends Area2D

# Dialogue configuration
@export_file("*.json") var dialogue_file: String = "res://json/nurse.json"
@export var dialogue_player_path: NodePath = "/root/RoomsArea/Dialogue"

var good_points: Node = null # Game state reference
var bad_points: Node = null # Game state reference
var dialogue_player: Node = null  # Reference to dialogue system

func _ready() -> void:
	# Get dialogue player node
	dialogue_player = get_node_or_null(dialogue_player_path)
	if dialogue_player == null:
		push_error("DialoguePlayer not found at path: " + str(dialogue_player_path))
	else:
		# Connect signals if available
		if dialogue_player.has_signal("option_selected"):
			dialogue_player.connect("option_selected", Callable(self, "_on_option_selected"))
		else:
			push_warning("DialoguePlayer missing signal: option_selected")
		if dialogue_player.has_signal("dialogue_finished"):
			dialogue_player.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

func _on_body_entered(body: Node2D) -> void:
	# Only trigger if player and nurse hasn't received letter
	if not body.is_in_group("player"):
		return
	
	# Get reference to nurse
	var nurse = get_tree().get_first_node_in_group("nurse")
	if nurse and nurse.has_method("has_received_letter") and nurse.has_received_letter:
		return  # Don't start dialogue if nurse already got letter
	
	# Check if player has love letter and can use it
	if QuestManager.has_quest_item("love_letter") and QuestManager.can_use_letter():
		# Use the letter giving dialogue
		dialogue_file = "res://json/nurseletter.json"
	else:
		# Use normal nurse dialogue
		dialogue_file = "res://json/nurse.json"
	
	# Original dialogue start logic
	if dialogue_player == null:
		return

	if not FileAccess.file_exists(dialogue_file):
		push_error("Dialogue file not found: " + dialogue_file)
		return
	
	dialogue_player.d_file = dialogue_file
	dialogue_player.start()

func _on_option_selected(option_index: int) -> void:
	# Handle dialogue option selection
	if dialogue_player == null:
		print("dialogue_player is null in _on_option_selected")
		return

	# Get current dialogue state
	var current = dialogue_player.get_current_dialogue()
	if current == null:
		print("current dialogue is null")
		return

	# Validate selected option
	var options = current.get("options", [])
	if option_index < 0 or option_index >= options.size():
		print("Invalid option index:", option_index)
		return

	var selected_option = options[option_index]
	if not selected_option.has("next_id"):
		print("Selected option has no next_id")
		return

	var next_id = selected_option["next_id"]
	print("Option selected, next_id is:", next_id)

	# Find next dialogue entry
	var next_dialogue = null
	for dialogue in dialogue_player.dialogue_data:
		if dialogue.get("id", "") == next_id:
			next_dialogue = dialogue
			break

	if next_dialogue == null:
		print("Could not find dialogue entry for next_id:", next_id)
		return

	# Handle special actions
	if next_dialogue.has("action"):
		var action = next_dialogue["action"]
		if action == "trigger_nurse_exit":
			# Give letter to nurse and trigger exit
			var nurse = get_tree().get_first_node_in_group("nurse")
			if nurse and nurse.has_method("receive_love_letter"):
				nurse.receive_love_letter()
			return
		elif action == "change_scene":
			var scene_path = next_dialogue.get("scene_path", "")
			if scene_path != "":
				print("Changing scene to:", scene_path)
				get_tree().change_scene_to_file(scene_path)
			else:
				print("scene_path is empty!")
			return

	# Continue dialogue normally
	if dialogue_player.has_method("goto_id"):
		dialogue_player.goto_id(next_id)
	else:
		print("dialogue_player missing method: goto_id")

func _on_interact():
	# Check if player has love letter and can use it
	if QuestManager.has_quest_item("love_letter") and QuestManager.can_use_letter():
		# Use the letter giving dialogue
		dialogue_file = "res://json/nurseletter.json"
	else:
		# Use normal nurse dialogue
		dialogue_file = "res://json/nurse.json"
	
	if dialogue_player == null:
		return
		
	print("Interacting with sad nurse")
	dialogue_player.d_file = dialogue_file
	dialogue_player.start()

func _on_dialogue_finished() -> void:
	# Dialogue finished handler
	print("Dialogue with sad nurse finished.")
	if good_points:
		print("Good points:", good_points)
	if bad_points:
		print("Bad points:", bad_points)
