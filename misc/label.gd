extends Label

@onready var e: Label = $"../E"
@onready var space: Label = $"../Space"
@onready var esc: Label = $"../Esc"




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		e.hide()
		return
		
	if event.is_action_pressed("ui_accept"):
		space.hide()
		
	if event.is_action_pressed("Settings"):
		esc.hide()
		
	
