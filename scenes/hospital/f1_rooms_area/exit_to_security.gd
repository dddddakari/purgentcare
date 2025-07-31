extends Area2D

# Dialogue configuration
@export_file("*.json") var dialogue_file: String = "res://json/leavingrooms.json"
@export var dialogue_player_path: NodePath = "/root/RoomsArea/Dialogue"

var dialogue_player: Node = null

func _ready() -> void:
	# Get dialogue system reference
	dialogue_player = get_node_or_null(dialogue_player_path)
	if dialogue_player == null:
		push_error("DialoguePlayer not found at path: " + str(dialogue_player_path))

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	print("DEBUG: Checking for sister_location_info...")
	print("DEBUG: Current quest items: ", QuestManager.get_all_quest_items())
	
	if not QuestManager.has_quest_item("sister_location_info"):
		print("DEBUG: Info not found - showing locked dialogue")
		_start_locked_dialogue()
	else:
		print("DEBUG: Info found - changing scene")
		get_tree().change_scene_to_file("res://scenes/hospital/f1_security/SecurityArea.tscn")
		
		
func _start_locked_dialogue():
	if dialogue_player == null or not FileAccess.file_exists(dialogue_file):
		return
	
	dialogue_player.d_file = dialogue_file
	dialogue_player.start()
	print("East Wing locked dialogue started")

# Optional: Add this if you want manual interaction too
func _on_interact():
	_on_body_entered(get_tree().get_first_node_in_group("player"))
