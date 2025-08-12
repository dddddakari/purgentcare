extends CharacterBody2D

# Movement constants and variables
const SPEED = 200
var current_dir = "none"
var can_move = true
var health = 100
var health_max = 100
var health_min = 0

var damage_to_deal = 15  # INCREASED: Finneas hits harder now!
var is_dealing_damage: bool = false
var can_take_damage = false
var dead: bool = false

#for combat
var enemy_inatk_range = false
var enemy_atk_cd = true
var attack_ip = false
var can_be_attacked := false
var enemies_in_attack_range = []
var attack_cooldown_timer = 0.0
var attack_cooldown_duration = 0.5

# ADDED: Damage immunity system to prevent spam damage
var damage_immunity_timer = 0.0
var damage_immunity_duration = 1.0  # 1 second of immunity after taking damage

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

# Updated _physics_process - REMOVED the problematic enemy_atk() call
func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return

	# Update damage immunity timer
	if damage_immunity_timer > 0:
		damage_immunity_timer -= delta

	velocity = Vector2.ZERO
	player_movement(delta)
	attack()
	
	if health <= 0:
		dead = true
		#game over screen here
		health = 0
		print("Finneas is dead!")

# Fixed attack function - instant attacks, no player cooldown
func attack():
	if Input.is_action_just_pressed("attack"):
		print("Player attacking! Enemies in range: %d" % enemies_in_attack_range.size())
		
		# Attack all enemies in range with YOUR damage_to_deal (Finneas's strength)
		for enemy in enemies_in_attack_range:
			if is_instance_valid(enemy) and enemy.has_method("take_damage"):
				enemy.take_damage(damage_to_deal)  # This is Finneas's damage (15)
				print("Finneas attacked %s for %d damage" % [enemy.name, damage_to_deal])
		
		Global.player_curr_atk = true
		attack_ip = true
		
		# Start the attack animation timer if it exists
		if has_node("deal_atk_timer"):
			$deal_atk_timer.start()

# Enhanced hitbox detection for player attacks
func _on_player_hitbox_body_entered(body: Node2D) -> void:
	# DON'T attack yourself, Finneas!
	if body == self or body.has_method("player"):
		print("Ignoring self/player in attack range: %s" % body.name)
		return
	
	# Check if it's an enemy (zombies should have enemy() method or take_damage method)
	if body.has_method("enemy") or body.has_method("take_damage"):
		if body not in enemies_in_attack_range:
			enemies_in_attack_range.append(body)
			print("Enemy entered Finneas's attack range: %s" % body.name)

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	# Don't process self/player
	if body == self or body.has_method("player"):
		return
		
	# Remove from attack range
	if body.has_method("enemy") or body.has_method("take_damage"):
		if body in enemies_in_attack_range:
			enemies_in_attack_range.erase(body)
			print("Enemy left Finneas's attack range: %s" % body.name)

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

# FIXED: Enhanced take_damage function with immunity system
func take_damage(amount: int):
	print("take_damage called with amount: %d, can_be_attacked: %s, immunity: %s" % [amount, can_be_attacked, damage_immunity_timer > 0])
	
	# Check immunity first
	if damage_immunity_timer > 0:
		print("Damage blocked - Finneas is immune!")
		return
	
	# Allow damage if can_be_attacked is true (for combat scenarios)
	if not can_be_attacked:
		print("Damage blocked - player not in combat mode")
		return
	
	var old_health = health
	health = max(health - amount, health_min)
	var actual_damage = old_health - health
	print("Damage taken: ", actual_damage, " (", old_health, " -> ", health, ")")
	
	# Start immunity period
	damage_immunity_timer = damage_immunity_duration
	print("Finneas gains %s seconds of damage immunity" % damage_immunity_duration)
	
	if health <= health_min:
		die()

# ADDED: Alternative damage method for zombie compatibility
func damage_player(amount: int):
	take_damage(amount)

func die():
	if dead:
		return
	
	dead = true
	can_move = false
	print("Finneas has died!")
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

func set_player_attackable(state: bool) -> void:
	can_be_attacked = state
	print("Finneas attackable state set to: %s" % state)
	
	# Ensure player is in the group for zombie detection
	if state and not is_in_group("player"):
		add_to_group("player")
		print("Finneas added to 'player' group for combat")
	
	# Reset immunity when entering/exiting combat
	if not state:
		damage_immunity_timer = 0.0

# REMOVED: The problematic enemy_atk() function that was causing double damage

func _on_attack_cd_timeout() -> void:
	enemy_atk_cd = true

func _on_deal_atk_timer_timeout() -> void:
	if has_node("deal_atk_timer"):
		$deal_atk_timer.stop()  # Don't restart automatically
	Global.player_curr_atk = false
	attack_ip = false
