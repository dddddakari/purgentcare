extends CanvasLayer

@export var correct_code := "1234" 
@onready var display = $Panel/Display

var current_input := ""

func _ready():
	hide()  # Start hidden

func _on_button_pressed(number: String):
	if current_input.length() < 4:  # Limit to 4 digits
		current_input += number
		display.text = current_input

func _on_clear_pressed():
	current_input = ""
	display.text = "[empty]"

func _on_confirm_pressed():
	if current_input == correct_code:
		unlock()
	else:
		display.text = "[WRONG]"
		await get_tree().create_timer(1.0).timeout
		_on_clear_pressed()

func unlock():
	display.text = "[ACCESS GRANTED]"
	$AnimationPlayer.play("unlock_animation")
	await $AnimationPlayer.animation_finished
	queue_free()  # Remove keypad after use
	# Add your reward/loot spawning here
