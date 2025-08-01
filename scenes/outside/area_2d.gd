extends Area2D

var entered = false


func _on_body_entered(_body: Node2D) -> void:
	if _body.name == "Player":  # Optional: ensure it's the player
		get_tree().change_scene_to_file.call_deferred("res://minigames/maze/MazeUI.tscn")


func _on_body_exited(_body: Node2D) -> void:
	entered = false
