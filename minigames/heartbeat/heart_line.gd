extends Area2D

signal game_result

@onready var heartbeat_moving: Area2D = $"../HeartbeatMoving"
var overlap = false
var score = 0

func _on_area_entered(area: Area2D) -> void:
	if area == heartbeat_moving:
		overlap = true

func _on_area_exited(area: Area2D) -> void:
	if area == heartbeat_moving:
		overlap = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if overlap:
			score = score + 1
			game_pass()
			print("Success")
		else:
			print("fail")

func game_pass():
	if score == 5:
		get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/b_rooms/penelope_room/PenelopeRoomLocked.tscn")
