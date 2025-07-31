extends Area2D

var entered = false 

func _on_body_entered(body: Node2D) -> void:
	if entered == true:
			use_dialogue()
	
func use_dialogue():
	var dialogue = get_parent().get_node("OPDialogue")
	if dialogue:
		dialogue.d_file = "res://json/op_dialogue.json"
		dialogue.start()
