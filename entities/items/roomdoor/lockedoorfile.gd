extends Area2D

@onready var interactable: Area2D = $interactable
var dialogue_system = null

func _ready():
	interactable.interact = _on_interact
	# Get the dialogue system reference
	dialogue_system = get_node_or_null("/root/RoomsArea/Dialogue")

func _on_interact():
	if QuestManager.has_quest_item("nurse_keycard"):
		open_file_room()
	else:
		play_locked_dialogue()

func open_file_room():
	print("Opening file room!")
	if dialogue_system:
		var dialogue_file = "res://json/filedoor.json"
		if FileAccess.file_exists(dialogue_file):
			dialogue_system.d_file = dialogue_file
			dialogue_system.start()
			print("Playing locked door dialogue")
		else:
			push_error("Locked door dialogue file not found: " + dialogue_file)
	else:
		push_error("Dialogue system not found")

func play_locked_dialogue():
	if dialogue_system:
		var dialogue_file = "res://json/lockedfileroom.json"  # Make sure this path is correct
		if FileAccess.file_exists(dialogue_file):
			dialogue_system.d_file = dialogue_file
			dialogue_system.start()
			print("Playing locked door dialogue")
		else:
			push_error("Locked door dialogue file not found: " + dialogue_file)
	else:
		push_error("Dialogue system not found")
