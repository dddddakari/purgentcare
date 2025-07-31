extends CharacterBody2D
class_name NPCBase

## Base class for all NPCs with common functionality.
## Inherit from this class to create specific NPC types.

### --- Enums --- ###
# Defines the possible states an NPC can be in
enum State {
	IDLE,       # Standing still, doing nothing
	WANDER,     # Moving randomly within a radius
	FOLLOW,     # Following a target (usually player)
	PATH,       # Following a predefined path
	DIALOGUE,   # In conversation with player
	CUSTOM      # Custom state for child classes to implement
}

### --- Exported Variables --- ###
# These can be set in the Godot editor for each NPC instance
@export_category("NPC Settings")
@export var move_speed: float = 30.0        # Maximum movement speed in pixels/second
@export var acceleration: float = 5.0       # How quickly the NPC reaches max speed
@export var wander_radius: float = 100.0    # How far from start position the NPC can wander
@export var detection_radius: float = 150.0 # How close player needs to be to detect

### --- Node References --- ###
# These will be automatically set to the child nodes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D      # Visual representation


### --- Member Variables --- ###
var current_state: State = State.IDLE      # Current behavior state
var player_ref: Node2D = null              # Reference to player when detected
var start_position: Vector2                # Original spawn position
var is_interactable: bool = true           # Can player interact with this NPC
var dialogue_file: String = ""             # Path to dialogue resource file
var destination: Vector2 = Vector2.ZERO    # Current movement target position

### --- Core Functions --- ###

# Called when the node enters the scene tree
func _ready():
	start_position = global_position       # Remember starting position
	destination = start_position           # Initialize destination
	initialize_npc()                       # Custom initialization
	

# Placeholder for NPC-specific initialization
# Override this in inherited classes
func initialize_npc():
	pass

# Sets up signals for player entering/exiting interaction area

# Main physics processing called every frame
func _physics_process(delta):
	handle_state(delta)    # Update behavior based on current state
	move_and_slide()       # Apply movement using Godot's physics

### --- State Management --- ###

# Handles behavior based on current state
func handle_state(delta):
	match current_state:
		State.IDLE:
			# Gradually slow down to stop
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		
		State.WANDER:
			handle_wander(delta)  # Random movement behavior
		
		State.FOLLOW:
			if player_ref:
				# Move toward player if they exist
				move_to_position(player_ref.global_position, delta)
		
		State.PATH:
			handle_path()  # Path following behavior
		
		State.DIALOGUE:
			velocity = Vector2.ZERO  # Stop moving during dialogue
		
		State.CUSTOM:
			handle_custom_state(delta)  # Custom behavior

# Basic wandering behavior - move randomly within radius
func handle_wander(delta):
	# If reached destination or random chance, pick new destination
	if is_at_destination() or randf() < 0.02:
		set_random_destination()
	# Move toward current destination
	move_to_position(destination, delta)

# Path following behavior (to be implemented by child classes)
func handle_path():
	pass

# Placeholder for custom state behavior
func handle_custom_state(delta):
	pass

### --- Movement Functions --- ###

# Moves NPC toward a target position
# @param target_position: Where to move toward
# @param delta: Time since last frame for smooth movement
func move_to_position(target_position: Vector2, delta: float):
	# Calculate direction to target
	var direction = (target_position - global_position).normalized()
	# Apply acceleration toward target speed
	velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
	# Update sprite direction
	update_facing_direction(direction)

# Updates sprite animation based on movement direction
# @param direction: Normalized Vector2 indicating movement direction
func update_facing_direction(direction: Vector2):
	# Flip sprite horizontally if moving left
	if abs(direction.x) > abs(direction.y):
		sprite.flip_h = direction.x < 0
	# Play walk animation if moving, idle if standing
	sprite.play("walk" if velocity.length() > 5 else "idle")

# Checks if NPC has reached its current destination
# @return: True if within 5 pixels of destination
func is_at_destination() -> bool:
	return global_position.distance_to(destination) < 5.0

# Sets a new random destination within wander radius
func set_random_destination():
	destination = start_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

### --- Player Interaction --- ###

# Called when a body enters interaction area
func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body  # Store reference to player
		if is_interactable:
			show_interaction_prompt(true)  # Show interaction UI

# Called when a body exits interaction area
func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null  # Clear player reference
		show_interaction_prompt(false)  # Hide interaction UI

# Shows or hides interaction prompt (to be implemented)
# @param show: Whether to show or hide the prompt
func show_interaction_prompt(show: bool):
	pass

# Called when player interacts with NPC
func interact():
	if dialogue_file != "":
		start_dialogue(dialogue_file)  # Start dialogue if available

# Begins dialogue sequence
# @param file: Path to dialogue resource
func start_dialogue(file: String):
	current_state = State.DIALOGUE  # Enter dialogue state
	# Implementation would call your dialogue system here
	# Example: DialogueManager.start_dialogue(file)

# Ends dialogue sequence
func end_dialogue():
	current_state = State.IDLE  # Return to idle state
