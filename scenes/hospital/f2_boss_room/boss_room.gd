# boss_room.gd
extends Node2D

# File path to the showdown dialogue
const DIALOGUE_FILE_PATH := "res://json/finalshowdown.json"

@export var good_ending_scene:= "res://scenes/hospital/Endings/bad_ending/good_ending.tscn"
@export var bad_ending_scene:= "res://scenes/hospital/Endings/bad_ending/bad_ending.tscn"

func _ready():
	use_dialogue()

# Start the final showdown dialogue
func use_dialogue():
	var dialogue = get_node_or_null("/root/FinalBossRoom/Dialogue")
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

# Handle special actions from dialogue
func _on_dialogue_action(action_name: String):
	match action_name:
		"boss_room_scene_change":
			_check_points_and_change_scene()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		_check_points_and_change_scene()

func _check_points_and_change_scene():
	# Defensive check to avoid nil access
	if GameState == null:
		push_error("GameState singleton not found!")
		return
	
	# Compare points from GameState autoload
	if GameState.good_points >= GameState.bad_points:
		print("Boss Room: Sending player to GOOD ending. Good points: %d, Bad points: %d" % [GameState.good_points, GameState.bad_points])
		get_tree().change_scene_to_file(good_ending_scene)
	else:
		print("Boss Room: Sending player to BAD ending. Good points: %d, Bad points: %d" % [GameState.good_points, GameState.bad_points])
		get_tree().change_scene_to_file(bad_ending_scene)
