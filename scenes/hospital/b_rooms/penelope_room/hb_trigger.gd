extends Area2D

signal admin_trigger

@onready var hb_trigger: Area2D = $"."

var entered = false
var dialogue_triggered = false

var set_dialogue_playable = false

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not dialogue_triggered:
		dialogue_triggered = true
		admin_trigger.emit()
		use_dialogue()
	else:
		entered = true

func set_playable():
	pass

func use_dialogue():
	var dialogue = get_parent().get_node("Dialogue")
	if dialogue:
		dialogue.d_file = "res://json/pen_room_minigame.json"
		dialogue.start()
