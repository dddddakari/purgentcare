#reference: https://www.youtube.com/watch?v=7CCofjq_dHM
extends CanvasLayer

signal start_combat  

@export_file("*.json") var d_file: String
const SampleButtonScene = preload("res://systems/dialoguesystem/Button.tscn")

var dialogue := []
var curr_dialogue_id := -1
var d_active := false
var id_map := {}

var player: Node2D = null
var waiting_for_input := false

var can_advance := true  # Controls if input can advance dialogue
#default state not hostile
var hostile = false


func _ready():
	print("DialoguePlayer: _ready called")
	$NinePatchRect.visible = false
	$Options.visible = false

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("[Warning] Player not found in group 'player'.")
	else:
		print("Player found:", player, " (Type: ", player.get_class(), ")")

# Later in your code, check if player has the method before calling it
func start():
	print("DialoguePlayer: start() called")
	if d_active:
		print("[Warning] Dialogue already active — skipping start().")
		return

	print("Starting dialogue with file:", d_file)
	d_active = true
	$NinePatchRect.visible = true

	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)
		print("Player movement disabled.")
	elif player:
		print("[Warning] Player doesn't have set_movement_enabled method")

	dialogue = load_dialogue()
	print("Dialogue size is:", dialogue.size())

	if dialogue.is_empty():
		print("[Warning] No dialogue found in file. Cancelling dialogue.")
		end_dialogue()
		return

	curr_dialogue_id = -1
	waiting_for_input = false
	can_advance = true
	print("Calling next_script() to start dialogue flow.")
	next_script()


func load_dialogue() -> Array:
	print("Loading dialogue JSON from:", d_file)
	if not FileAccess.file_exists(d_file):
		push_error("Dialogue file not found: " + d_file)
		return []

	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = file.get_as_text()
	print("Raw JSON content:", content)

	var data = JSON.parse_string(content)
	if data == null:
		push_error("Failed to parse JSON.")
		return []

	if typeof(data) != TYPE_ARRAY:
		push_error("JSON root is not an array.")
		return []

	id_map.clear()
	for i in data.size():
		if data[i].has("id"):
			id_map[data[i]["id"]] = i

	print("Parsed", data.size(), "dialogue entries.")
	print("ID map contents:", id_map)
	return data


func _process(delta):
	if not d_active:
		return
		
	if waiting_for_input and not $Options.visible and can_advance 	and Input.is_action_just_pressed("ui_accept"):
		var line = dialogue[curr_dialogue_id]

	# 1) If the line points somewhere explicit, follow it
		if line.has("next_id") and line["next_id"] != "":
			waiting_for_input = false
			can_advance = false
			next_script(line["next_id"])
			return

	# 2) Otherwise fall back to sequential order if there *is* a next entry
		if curr_dialogue_id + 1 < dialogue.size():
			waiting_for_input = false
			can_advance = false
			next_script()           # go to the next array element
			return

	# 3) No next_id *and* no more lines – we’re at the real end
		end_dialogue()



func next_script(optional_id = null):
	$Options.visible = false
	clear_options()

	if optional_id != null:
		curr_dialogue_id = id_map.get(optional_id, -1)
		if curr_dialogue_id == -1:
			print("[Warning] next_id '%s' not found in dialogue." % optional_id)
			end_dialogue()
			return
	else:
		curr_dialogue_id += 1

	# Check if we've reached the end of the dialogue
	if curr_dialogue_id < 0 or curr_dialogue_id >= dialogue.size():
		end_dialogue()
		return

	var current_line = dialogue[curr_dialogue_id]

# Handle actions (regardless of whether there's text)
# Handle actions (regardless of whether there's text)
	if current_line.has("action"):
		match current_line["action"]:
			"change_scene":
				var scene_path = current_line.get("scene_path", "")
				if scene_path != "":
					print("Action: Changing scene to:", scene_path)
					get_tree().change_scene_to_file(scene_path)
					return
				else:
					print("scene_path is empty!")
					end_dialogue()
					return
			"conditional_scene_change":
				print("Action: Conditional scene change triggered")
				_handle_conditional_scene_change()
				return
			"start_combat":
				print("Action: Starting combat")
				hostile = true
				emit_signal("start_combat")
			"complete_quest_good":
				print("DialogueSystem: Completing quest via GOOD path")
				QuestManager.complete_quest_good()
				var nurse = get_tree().get_first_node_in_group("nurse")
				if nurse:
					nurse.receive_love_letter()  # This will trigger the exit
			"nurse_exit":
				var nurse = get_tree().get_first_node_in_group("nurse")
				if nurse:
					nurse.start_emotional_exit()
			"trigger_nurse_exit":
				var nurse = get_tree().get_first_node_in_group("nurse")
				if nurse:
					print("Found nurse, triggering exit")
					nurse.receive_love_letter()
				else:
					print("ERROR: No nurse found in group")
				QuestManager.complete_quest_good()

# Display text and name if present
	var name_label = $NinePatchRect.get_node("name")
	var text_label = $NinePatchRect.get_node("text")

	name_label.text = current_line.get("name", "")
	text_label.text = current_line.get("text", "")

	print("Displaying:", name_label.text, "-", text_label.text)

	if current_line.has("options") and current_line["options"].size() > 0:
		show_options(current_line["options"])
		waiting_for_input = false
		can_advance = false
	else:
		waiting_for_input = true
		can_advance = true
		
		
func _handle_conditional_scene_change():
	print("DEBUG: Handling conditional scene change...")
	print("DEBUG: Current path chosen: ", QuestManager.path_chosen)
	
	if QuestManager.path_chosen == "bad":
		print("DEBUG: Loading cabinet-spilled scene (bad path)")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_rooms_area/Room_AreaCabinetSpilled.tscn")
	elif QuestManager.path_chosen == "good":
		print("DEBUG: Loading unlocked scene (good path)")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_rooms_area/Room_AreaUnlocked.tscn")
	else:
		print("DEBUG: No path chosen yet, loading default unlocked scene")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_rooms_area/Room_AreaUnlocked.tscn")



func show_options(options_array):
	print("show_options called with %d options" % options_array.size())
	$Options.visible = true
	for option_data in options_array:
		var btn = SampleButtonScene.instantiate()
		btn.text = option_data.get("text", "...")
		# Use .bind to pass next_id string properly
		btn.pressed.connect(self._on_option_selected.bind(option_data.get("next_id", "")))
		$Options.add_child(btn)
		print("Option button added with text:", btn.text)


func _on_option_selected(next_id: String) -> void:
	print("Option selected, next id:", next_id)
	
	# Disable all buttons immediately to prevent multiple triggers
	for btn in $Options.get_children():
		btn.disabled = true

	$Options.visible = false
	clear_options()

	waiting_for_input = false
	can_advance = false  # Lock input immediately on option select

	# Find next dialogue entry from id_map
	var next_index = id_map.get(next_id, -1)
	if next_index == -1:
		print("next_id not found:", next_id)
		end_dialogue()
		return
	
	# Use call_deferred to prevent immediate input detection
	call_deferred("_deferred_next_script", next_id)


func _deferred_next_script(next_id: String) -> void:
	next_script(next_id)


func clear_options():
	var count = $Options.get_child_count()
	print("Clearing %d option buttons." % count)
	for child in $Options.get_children():
		child.queue_free()



func end_dialogue():
	print("\n--- end_dialogue called ---")
	if not d_active:
		print("Dialogue already inactive; nothing to end.")
		return

	d_active = false
	waiting_for_input = false
	can_advance = false
	$NinePatchRect.visible = false
	$Options.visible = false
	clear_options()

	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(true)
		print("Movement re-enabled in end_dialogue().")
	elif player:
		print("[Warning] Player doesn't have set_movement_enabled method")
