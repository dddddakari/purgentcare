# HostileZombies.gd - Updated with death signal
extends CharacterBody2D

# Add this signal at the top
signal zombie_died

@export var health: int = 100
@export var zombie_damage: int = 10  # How much damage the ZOMBIE deals to Finneas
@export var speed: float = 50.0

# Combat components - make sure these match your scene structure
@onready var hitbox_area: Area2D = $enemy_hitbox
@onready var detect_area: Area2D = $detection_area
@onready var hitbox_shape: CollisionShape2D = $enemy_hitbox/CollisionShape2D
@onready var detect_shape: CollisionShape2D = $detection_area/CollisionShape2D

var is_hostile: bool = false
var player: CharacterBody2D = null
var attack_timer: float = 0.0
var attack_cooldown: float = 1.5  # ZOMBIE's attack cooldown (they attack slower)
var is_dying: bool = false  # Prevent double death

func _ready():
	# Start non-hostile
	set_hostile(false)
	
	# Connect combat signals
	if hitbox_area:
		hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	if detect_area:
		detect_area.body_entered.connect(_on_detection_body_entered)
		detect_area.body_exited.connect(_on_detection_body_exited)

func enemy():
	# Identifies this as an enemy for the player's attack system
	pass

func set_hostile(hostile: bool):
	is_hostile = hostile
	print("%s set_hostile called with: %s" % [name, hostile])
	
	# Enable/disable combat areas
	if hitbox_area:
		hitbox_area.monitoring = hostile
	if detect_area:
		detect_area.monitoring = hostile
	if hitbox_shape:
		hitbox_shape.disabled = !hostile
	if detect_shape:
		detect_shape.disabled = !hostile
	
	print("%s combat areas enabled: %s" % [name, hostile])

func _physics_process(delta):
	if not is_hostile or is_dying:
		return
		
	# Update ZOMBIE's attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
	
	# Move towards player if detected
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_detection_body_entered(body):
	if not is_hostile:
		return
		
	if body.is_in_group("player"):
		player = body
		print("%s detected player: %s" % [name, body.name])

func _on_detection_body_exited(body):
	if body == player:
		player = null
		print("%s lost player" % name)

func _on_hitbox_body_entered(body):
	if not is_hostile:
		return
		
	if body.is_in_group("player") and attack_timer <= 0:
		attack_player(body)
		attack_timer = attack_cooldown  # Set the ZOMBIE's cooldown

func attack_player(player_body):
	print("%s attacking player for %d damage!" % [name, zombie_damage])
	if player_body.has_method("take_damage"):
		player_body.take_damage(zombie_damage)  # Zombie's damage to Finneas
	elif player_body.has_method("damage_player"):
		player_body.damage_player(zombie_damage)

func take_damage(amount: int):
	if is_dying:
		return
		
	# This is called when FINNEAS attacks the zombie
	health -= amount
	print("%s took %d damage from Finneas! Health: %d" % [name, amount, health])
	
	if health <= 0:
		die()

func die():
	if is_dying:
		return
		
	is_dying = true
	print("%s was defeated by Finneas!" % name)
	
	# Emit death signal BEFORE queue_free
	zombie_died.emit()
	print("%s emitted death signal" % name)
	
	# Optional: Play death animation or effect here
	play_death_effect()
	
	# Remove from scene
	queue_free()

func play_death_effect():
	# Add death animation, sound, particles, etc. here
	print("%s playing death effect" % name)
	# Example: 
	# $DeathAnimation.play()
	# $DeathSound.play()
	# await $DeathAnimation.finished  # Wait for animation if needed
