extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

var dialogue_system = null
var last_dialogue_id = ""
var was_picked_up = false

func _ready() -> void:
	interactable.interact = _on_interact
	
	# Only hide if actually picked up
	if QuestManager.has_quest_item("nurse_keycard"):
		was_picked_up = true
		visible = false
		set_process(false)
		interactable.set_process(false)

func _on_interact():
	if was_picked_up:
		return
	
	print("Keycard interaction started")
	use_dialogue()

func use_dialogue():
	dialogue_system = get_parent().get_node("/root/RoomsArea/Dialogue")
	var dialogue_file_path = "res://json/keycard_unhappy.json"
	
	if dialogue_system:
		if FileAccess.file_exists(dialogue_file_path):
			dialogue_system.d_file = dialogue_file_path 
			dialogue_system.start()
			print("Keycard dialogue started")
			_monitor_dialogue()
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)

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
	
	# Only pick up if player chose to take it
	if last_dialogue_id == "Stealing":
		print("Player took the keycard")
		was_picked_up = true
		QuestManager.add_quest_item("nurse_keycard")
		visible = false
		set_process(false)
		interactable.set_process(false)
	else:
		print("Player left the keycard")
		# Reset interaction state
		interactable.set_process(true)
	
	last_dialogue_id = ""
