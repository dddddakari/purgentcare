# bad_ending.gd - Updated with zombie elimination detection
extends Node2D

const DIALOGUE_FILE_PATH := "res://json/badendingfight.json"

@onready var dialogue = $Dialogue
@onready var zombies = [
	$HostileZombies,
	$HostileZombies2, 
	$HostileZombies3
]

var combat_started = false
var victory_triggered = false

func _ready():
	use_dialogue()

func _process(_delta):
	# Check for victory condition if combat has started
	if combat_started and not victory_triggered:
		check_victory_condition()

func use_dialogue():
	if not dialogue:
		push_error("Dialogue node not found!")
		return
	
	if not FileAccess.file_exists(DIALOGUE_FILE_PATH):
		push_error("Dialogue file not found: " + DIALOGUE_FILE_PATH)
		return
	
	dialogue.d_file = DIALOGUE_FILE_PATH
	dialogue.connect("action_triggered", Callable(self, "_on_dialogue_action"))
	dialogue.start()
	print("Bad ending dialogue started.")

func _on_dialogue_action(action: String):
	print("Dialogue action received: ", action)
	if action == "start_combat":
		start_boss_combat()

func start_boss_combat():
	print("Starting boss combat!")
	combat_started = true
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_player_attackable"):
		player.set_player_attackable(true)
		print("Player set to attackable")

	# Activate all zombies
	for i in range(zombies.size()):
		var z = zombies[i]
		if z and z.has_method("set_hostile"):
			z.set_hostile(true)
			print("Activated zombie:", z.name)
			
			# Connect to their death signal if they have one
			if z.has_signal("zombie_died"):
				z.zombie_died.connect(_on_zombie_defeated)
		else:
			print("Failed to find or activate zombie:", z)
			# Remove invalid zombies from the list
			zombies[i] = null

	# Clean up null entries
	zombies = zombies.filter(func(z): return z != null)
	print("Total zombies in combat: ", zombies.size())

func check_victory_condition():
	# Count remaining alive zombies
	var alive_zombies = 0
	for zombie in zombies:
		if is_instance_valid(zombie):
			alive_zombies += 1
	
	print("Alive zombies: ", alive_zombies)
	
	# If no zombies are alive, trigger victory
	if alive_zombies == 0:
		trigger_victory()

func _on_zombie_defeated():
	print("A zombie was defeated!")
	# This will be caught by the next _process check
	
func trigger_victory():
	if victory_triggered:
		return
		
	victory_triggered = true
	print("🎉 VICTORY! All zombies eliminated!")
	
	# Disable player combat
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_player_attackable"):
		player.set_player_attackable(false)
		print("Player combat disabled")
	
	# Start victory sequence
	start_victory_animation()

func start_victory_animation():
	print("Starting victory animation sequence...")
	
	# Option 1: Play an AnimationPlayer
	var anim_player = get_node_or_null("VictoryAnimationPlayer")
	if anim_player:
		anim_player.play("victory_sequence")
		print("Playing victory animation")
	
	# Option 2: Start dialogue sequence
	var victory_dialogue_path = "res://json/victory_dialogue.json"
	if FileAccess.file_exists(victory_dialogue_path):
		if dialogue:
			dialogue.d_file = victory_dialogue_path
			dialogue.start()
			print("Starting victory dialogue")
	
	# Option 3: Change scene after delay
	await get_tree().create_timer(3.0).timeout
	change_to_ending_scene()

func change_to_ending_scene():
	print("Changing to ending scene...")
	# Replace with your actual ending scene path
	get_tree().change_scene_to_file("res://scenes/hospital/Endings/bad_ending/BadEndingAnimation.tscn")
