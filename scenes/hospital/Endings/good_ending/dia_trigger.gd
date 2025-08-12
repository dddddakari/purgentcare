extends Area2D

var entered = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		use_dialogue()
	else:
		entered = true
		
func use_dialogue():
	var dialogue = get_parent().get_node("Dialogue")
	if dialogue:
		dialogue.d_file = "res://json/good_end_inject.json"
		dialogue.start()
