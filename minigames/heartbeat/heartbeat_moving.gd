extends Area2D

var set_start = false
var velocity = Vector2()
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	randomize()

func _process(delta):
	if set_start:
		heartbeat()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not set_start:
		start_game()

func heartbeat():
	var speed = randf_range(5.0, 20.0)  
	velocity = Vector2(-speed, 0)
	
	translate(velocity)
	
	print("Speed:", -velocity.x)
	
	# Wrap around to the right when off-screen on the left
	if position.x < -50:
		position.x = screen_size.x + 50

func start_game():
	set_start = true
