extends TextureButton


func _on_pressed():
	get_tree().paused = false
	# Hide the pause menu
	get_parent().visible = false
	# Or remove the pause menu entirely
	# get_parent().queue_free()
