#ref https://www.youtube.com/watch?v=24hXJnwRim0
extends CharacterBody2D

var lebron_hostile = false    

@export_node_path("CanvasLayer") var dialogue_player_path : NodePath = "SecurityDialogue"

var dialogue_player : CanvasLayer


var speed = 35
var player_chase = false
var player = null

var health = 80
var player_inatk_zone = false
var can_take_dmg = true
var dead = false
var player_base_atk = 15


func _physics_process(delta: float):
	deal_with_dmg()
	
	if player_chase:
		position += (player.position - position)/speed
		
	if health <= 0:
		dead = true
		health = 0
		print("lebron dethroned")
		self.queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	player_chase = false

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inatk_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inatk_zone = false

func deal_with_dmg():
	if player_inatk_zone and Global.player_curr_atk == true:
		if can_take_dmg == true:
			health = health - player_base_atk
			$take_dmg_cd.start()
			can_take_dmg = false
			print("lebron health = ", health)

func _on_take_dmg_cd_timeout() -> void:
	can_take_dmg = true
