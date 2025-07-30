extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

# Dialogue configuration
@export_file("*.json") var dialogue_file: String = "res://json/keycard.json"
@export_file("*.json") var locked_file_room_dialogue: String = "res://json/lockedfileroom.json"
var dialogue_system = null
var last_dialogue_id = ""
var was_picked_up = false

func _ready() -> void:
	print("Keycard loaded at position: ", global_position)
	interactable.interact = _on_interact
	
	if QuestManager.has_quest_item("nurse_keycard"):
		was_picked_up = true
		hide_keycard()
	else:
		print("Keycard available for pickup")

func pick_up_keycard():
	print("Player took the keycard at position: ", global_position)
	was_picked_up = true
	QuestManager.add_quest_item("nurse_keycard")
	hide_keycard()
	print("Keycard added to inventory")

func _on_interact():
	if was_picked_up:
		return
	
	print("Keycard interaction started")
	use_dialogue()

func use_dialogue():
	dialogue_system = get_parent().get_node("/root/RoomsArea/Dialogue")
	
	if dialogue_system:
		if FileAccess.file_exists(dialogue_file):
			dialogue_system.d_file = dialogue_file 
			dialogue_system.start()
			print("Keycard dialogue started")
			_monitor_dialogue()
		else:
			push_error("Dialogue file not found: " + dialogue_file)

func _monitor_dialogue():
	if dialogue_system and dialogue_system.d_active:
		if dialogue_system.curr_dialogue_id >= 0 and dialogue_system.curr_dialogue_id < dialogue_system.dialogue.size():
			var current_dialogue = dialogue_system.dialogue[dialogue_system.curr_dialogue_id]
			if current_dialogue.has("id"):
				last_dialogue_id = current_dialogue["id"]
		
		await get_tree().process_frame
		if dialogue_system.d_active:
			_monitor_dialogue()
		else:
			_on_dialogue_finished()

func _on_dialogue_finished():
	print("Keycard dialogue finished with ID: ", last_dialogue_id)
	
	# Check which option was chosen (happy or unhappy path)
	if last_dialogue_id == "Love_Confession" or last_dialogue_id == "Stealing":
		pick_up_keycard()
	else:
		print("Player left the keycard")
		# Reset interaction state
		interactable.set_process(true)
	
	last_dialogue_id = ""

func hide_keycard():
	visible = false
	set_process(false)
	interactable.set_process(false)

# Call this from your file room door script
func try_open_file_room():
	if QuestManager.has_quest_item("nurse_keycard"):
		return true  # Door can be opened
	else:
		play_locked_dialogue()
		return false  # Door remains locked

func play_locked_dialogue():
	dialogue_system = get_parent().get_node("/root/RoomsArea/Dialogue")
	if dialogue_system and FileAccess.file_exists(locked_file_room_dialogue):
		dialogue_system.d_file = locked_file_room_dialogue
		dialogue_system.start()
		print("Playing locked file room dialogue")
