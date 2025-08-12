extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	use_dialogue()
	
func use_dialogue():
	var dialogue = get_parent().get_node("Dialogue2")
	var dialogue_file_path = "res://json/good_end_inject.json"

	if dialogue:
		dialogue.start() 
		print("yosef dialogue started.")
