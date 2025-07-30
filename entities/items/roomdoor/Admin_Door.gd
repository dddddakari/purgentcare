extends Area2D

@export var keypad_scene : PackedScene

func _on_body_entered(body):
	if body.is_in_group("player"):
		var keypad = keypad_scene.instantiate()
		get_tree().current_scene.add_child(keypad)
		keypad.show()
