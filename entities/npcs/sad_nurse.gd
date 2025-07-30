extends CharacterBody2D
class_name NPCNurse

# Movement settings
@export var move_distance: float = 40.0
@export var walk_speed: float = 50.0
@export var min_stop_time: float = 0.2
@export var max_stop_time: float = 1.0
@export var stop_chance: float = 0.03
@export var exit_speed: float = 150.0  # Faster speed for leaving

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var keycard_scene = preload("res://entities/items/keycard/keycard.tscn")

# State variables
var start_position: Vector2
var target_position: Vector2
var is_moving: bool = true
var moving_up: bool = true
var is_distracted: bool = false
var has_received_letter: bool = false
var is_leaving: bool = false
var exit_target: Vector2
var can_receive_letter: bool = true  # New flag to prevent duplicate submissions

func _ready():
	add_to_group("nurse") 
	start_position = position
	target_position = start_position + Vector2(0, -move_distance)
	sprite.play("idle")
	timer.timeout.connect(_on_timer_timeout)
	print("Nurse initialized in group: ", is_in_group("nurse"))  # Debug


func _physics_process(delta):
	if is_leaving:
		# Special handling for exit movement
		var direction = (exit_target - position).normalized()
		velocity = direction * exit_speed
		move_and_slide()
		
		if position.distance_to(exit_target) < 20.0:
			print("Nurse: Reached exit point!")
			set_physics_process(false)
			queue_free()
	elif is_moving and not is_leaving:  # Only do normal movement if not leaving
		# Original movement logic
		var direction = (target_position - position).normalized()
		velocity = direction * walk_speed
		move_and_slide()
		
		if position.distance_to(target_position) < 5.0:
			switch_direction()
		
		if randf() < stop_chance * delta * 60:
			stop_walking()

func update_facing_direction(direction: Vector2):
	if is_leaving:
		sprite.play("walk_s")  # Force walking down animation during exit
	elif direction.length() > 0.1:
		if is_moving:
			sprite.play("walk_n" if direction.y < 0 else "walk_s")
		else:
			sprite.play("idle")

func receive_love_letter():
	if QuestManager.cabinet_knocked:
		print("Nurse won't accept letter after cabinet was knocked")
		return
	
	print("NPC Nurse: Received love letter!")
	QuestManager.set_letter_used()
	QuestManager.set_nurse_left()  # Add this line
	can_receive_letter = false
	has_received_letter = true
	is_moving = false
	sprite.play("happy")
	start_emotional_exit()
	
func start_emotional_exit():
	print("Nurse: Starting emotional exit!")
	is_leaving = true
	is_moving = false
	exit_target = global_position + Vector2(0, 500)
	drop_keycard()
	sprite.play("walk_s")
	
	# Remove after exiting
	await get_tree().create_timer(2.0).timeout  # Wait for exit animation

func drop_keycard():
	print("Nurse: Dropping keycard!")
	var keycard = keycard_scene.instantiate()
	keycard.position = global_position + Vector2(20, 20)
	get_parent().call_deferred("add_child", keycard)  # Safer addition to scene tree


func switch_direction():
	moving_up = !moving_up
	if moving_up:
		target_position = start_position + Vector2(0, -move_distance)
	else:
		target_position = start_position + Vector2(0, move_distance)

func stop_walking():
	if is_moving:
		is_moving = false
		sprite.play("idle")
		timer.start(randf_range(min_stop_time, max_stop_time))

func resume_walking():
	if not is_moving:
		is_moving = true
		# Resume with correct walk animation
		var direction = (target_position - position).normalized()
		update_facing_direction(direction)


func _on_timer_timeout():
	if has_received_letter and not is_leaving:
		start_emotional_exit()
	elif is_leaving:
		queue_free() # Nurse disappears after leaving
	else:
		# Original timer behavior
		if is_distracted or has_received_letter:
			is_distracted = false
			has_received_letter = false
			sprite.play("idle")
			timer.start(randf_range(1.0, 2.0))
		else:
			resume_walking()

func react_to_distraction():
	print("NPC Nurse: Reacting to distraction!")
	is_distracted = true
	stop_walking()
	sprite.play("surprised")
	timer.start(5.0)
