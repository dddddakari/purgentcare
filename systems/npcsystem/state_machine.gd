extends Node
class_name NPCState

## NPC state machine template, you could attach to the npc state or just copy this INTO the NPC.gd if you want a single file

# The starting state when this NPC loads (set in Inspector)
@export var initial_state: NodePath

# Current active state and dictionary of all available states
var current_state: NPCState
var states: Dictionary = {}  # Stores all child states by name

func _ready():
	# Set up all child states when the node loads
	for child in get_children():
		if child is NPCState:  # Only register nodes that are NPCStates
			# Store state in dictionary with lowercase name as key
			states[child.name.to_lower()] = child
			# Give each state reference back to this state machine
			child.state_machine = self
	
	# Start with the initial state if specified
	if initial_state:
		change_state(get_node(initial_state).name)

## Transition to a new state
func change_state(new_state_name: String):
	# Look up the new state in our dictionary
	var new_state = states.get(new_state_name.to_lower())
	
	# Only proceed if the state exists and isn't already current
	if new_state and new_state != current_state:
		# Clean up the old state if one exists
		if current_state:
			current_state.exit()  # Let current state run exit logic
		
		# Switch to new state
		current_state = new_state
		current_state.enter()  # Let new state run enter logic

# Pass through standard processing to active state
func _process(delta):
	if current_state:
		current_state.update(delta)  # Handle frame-by-frame logic

# Pass through physics processing to active state
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)  # Handle physics updates

# Pass through input events to active state
func _unhandled_input(event):
	if current_state:
		current_state.handle_input(event)  # Let state handle input
