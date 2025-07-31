extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Check if it's the player
		# Transition to maze scene
		get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/b_hallway_area/B_HallwayArea.tscn")
