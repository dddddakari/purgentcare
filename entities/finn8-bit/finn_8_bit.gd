extends CharacterBody2D

const SPEED = 200
var current_dir = "none"
var can_move = true

func _ready():
	$Sprite2D.play("default")
	add_to_group("player")

func set_movement_enabled(enabled: bool) -> void:
	can_move = enabled
	print("set_movement_enabled called with:", enabled)
	if not enabled:
		velocity = Vector2.ZERO
		move_and_slide()

func _physics_process(delta):
	player_movement(delta)

func player_movement(delta):
	if not can_move:
		return

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		velocity.y = -SPEED
		velocity.x = 0
	else: 
		velocity = Vector2.ZERO
	
	move_and_slide()
