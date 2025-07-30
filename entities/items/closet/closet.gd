extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

var usable = false

func _ready() -> void:
	$ColorRect.visible = false
	
func _on_interact():
	$ColorRect.visible = true
	use_dialogue()
	
func set_usable():
	usable = true
	interactable.interact = _on_interact
	
func use_dialogue():
	var dialogue = get_parent().get_node("./Dialogue")
	var dialogue_file_path = "res://json/pen_closet.json"


	if dialogue:
			if FileAccess.file_exists(dialogue_file_path):
				dialogue.d_file = dialogue_file_path 
				dialogue.start()                    
				print("closet dialogue started.")
			else:
				push_error("Dialogue file not found: " + dialogue_file_path)


func _on_hb_trigger_admin_trigger() -> void:
	set_usable()
