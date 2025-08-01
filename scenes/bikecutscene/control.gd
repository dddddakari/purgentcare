# control.gd
extends Node2D

func _ready():
	# Start sonic cutscene
	$InputBlocker.visible = true  # Block input during cutscene
	$AnimatedSprite2D.play("SONIC")
	$AnimatedSprite2D.animation_finished.connect(_on_cutscene_finished)

func _on_cutscene_finished():
	# Cutscene finished handler
	$InputBlocker.visible = false  # Re-enable input
	# Transition to next scene
	get_tree().change_scene_to_file("res://scenes/outside/black_screen.tscn")
