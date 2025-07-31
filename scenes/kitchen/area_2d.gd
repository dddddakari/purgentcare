extends Area2D

var entered = false  # Track if player entered area

func _on_body_entered(_body: Node2D) -> void:
	# Handle player entering area
	if _body.name == "Player":  # Check if it's the player
		# Transition to maze scene
		get_tree().change_scene_to_file.call_deferred("res://scenes/bikecutscene/bike.tscn")

func _on_body_exited(_body: Node2D) -> void:
	# Handle player exiting area
	entered = false
