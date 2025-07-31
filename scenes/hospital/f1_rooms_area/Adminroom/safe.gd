extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

var dialogue_system = null
var last_dialogue_id = ""
var has_been_opened: bool = false  # Track if safe was already opened

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	use_dialogue()
		
func use_dialogue():
	dialogue_system = get_parent().get_node("/root/AdminRoom/Dialogue")
	var dialogue_file_path = "res://json/safedialogue.json"
	
	if dialogue_system:
		if FileAccess.file_exists(dialogue_file_path):
			dialogue_system.d_file = dialogue_file_path 
			dialogue_system.start()
			print("Safe dialogue started.")
			
			# Start monitoring the dialogue system
			_monitor_dialogue()
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)

func _monitor_dialogue():
	# Check dialogue state every frame while it's active
	if dialogue_system and dialogue_system.d_active:
		# Store the current dialogue ID for when dialogue ends
		if dialogue_system.curr_dialogue_id >= 0 and dialogue_system.curr_dialogue_id < dialogue_system.dialogue.size():
			var current_dialogue = dialogue_system.dialogue[dialogue_system.curr_dialogue_id]
			if current_dialogue.has("id"):
				last_dialogue_id = current_dialogue["id"]
		
		# Continue monitoring next frame
		await get_tree().process_frame
		if dialogue_system.d_active:
			_monitor_dialogue()
		else:
			# Dialogue has ended, handle the result
			_on_dialogue_finished()

func _on_dialogue_finished():
	print("Safe: Dialogue finished with ID: ", last_dialogue_id)
	
	if last_dialogue_id == "found_info" and not has_been_opened:
		print("DEBUG: Attempting to add sister_location_info")
		has_been_opened = true
		QuestManager.add_quest_item("sister_location_info")
		print("DEBUG: Current quest items: ", QuestManager.get_all_quest_items())
	else:
		print("DEBUG: Not adding item - Condition not met (ID:", last_dialogue_id, "Opened:", has_been_opened, ")")
	
	last_dialogue_id = ""
