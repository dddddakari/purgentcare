# reference: https://youtu.be/pQINWFKc9_k?si=Zvoeen96w5BuHBYm

extends Node2D

var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			
			await current_interactions[0].interact.call()
			
			can_interact = true

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
