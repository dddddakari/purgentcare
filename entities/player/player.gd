extends CharacterBody2D

# Movement constants and variables
const SPEED = 200
var current_dir = "none"
var can_move = true
var health = 100
var health_max = 100
var health_min = 0

var damage_to_deal = 15
var is_dealing_damage: bool = false
var can_take_damage = false
var dead: bool = false

#for combat
var enemy_inatk_range = false
var enemy_atk_cd = true
var attack_ip = false
var can_be_attacked := false

# Adds him as a different group so it's easier to signal for him
# so NPCs can't accidentally trigger things.
func _ready():
	add_to_group("player")
	print("Player group membership after adding:", is_in_group("player"))

func set_movement_enabled(_body):
	player_movement(true)

func _on_interaction_area_body_entered(_body):
	print("Player entered area:", _body.name)
	if _body.has_method("_on_interaction_area_body_entered"):
		print("Body has interaction handler")

func _on_interaction_area_body_exited(body):
	print("Player exited area:", body.name)

func _physics_process(_delta):
	player_movement(_delta)
	enemy_atk()
	attack()
	
	if health <= 0:
		dead = true
		#game over screen here
		health = 0
		print("dead")

func player_movement(_delta):
	if not can_move:
		return

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
	else: 
		play_anim(0)
		velocity = Vector2.ZERO
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $Sprite2D
		
	if dir == "right":
		anim.flip_h = true
		anim.play("walking_left" if movement == 1 else "to_the_side")
	elif dir == "left":
		anim.flip_h = false
		anim.play("walking_left" if movement == 1 else "to_the_side")
	elif dir == "up":
		anim.flip_h = false
		anim.play("walking_back" if movement == 1 else "back_idle")
	elif dir == "down":
		anim.flip_h = false
		anim.play("walking" if movement == 1 else "default")

# Health system functions for item usage
func restore_health(amount: int):
	var old_health = health
	health = min(health + amount, health_max)
	var actual_restore = health - old_health
	print("Health restored: ", actual_restore, " (", old_health, " -> ", health, ")")
	
	# Optional: Show health restore effect
	show_health_restore_effect(actual_restore)

func show_health_restore_effect(amount: int):
	# Create a floating text effect or screen flash
	print("+" + str(amount) + " Health!")
	# You could add a tween here to show floating text or screen effects

# Take damage function (existing functionality enhanced)
func take_damage(amount: int):
	if not can_take_damage:
		return
	
	var old_health = health
	health = max(health - amount, health_min)
	var actual_damage = old_health - health
	print("Damage taken: ", actual_damage, " (", old_health, " -> ", health, ")")
	
	if health <= health_min:
		die()

func die():
	if dead:
		return
	
	dead = true
	can_move = false
	print("Player has died!")
	# Add death animation/effects here

# Heal to full (for debugging or special items)
func heal_to_full():
	restore_health(health_max - health)

# Check if player can be healed
func can_heal() -> bool:
	return health < health_max

# Get health percentage (useful for UI)
func get_health_percentage() -> float:
	return float(health) / float(health_max)

#combat
func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inatk_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inatk_range = false

func set_player_attackable(state: bool) -> void:
	can_be_attacked = state

func enemy_atk():
	if enemy_inatk_range and enemy_atk_cd and can_be_attacked == true:
		health = health - 5
		enemy_atk_cd = false
		$attack_cd.start()
		print("Finn health: ", health)

func _on_attack_cd_timeout() -> void:
	enemy_atk_cd = true


func attack():
	if Input.is_action_just_pressed("attack"):
		Global.player_curr_atk = true
		#add anim code here


func _on_deal_atk_timer_timeout() -> void:
	$deal_atk_timer.start()
	Global.player_curr_atk = false
	attack_ip = false
