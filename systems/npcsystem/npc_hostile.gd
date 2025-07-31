extends NPCBase
class_name NPC_Hostile

@export var speed: float = 150  # Movement speed

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		print("Enemy found player: ", player_ref.name)
	else:
		print("Enemy failed to find player")
		set_physics_process(false)

func _physics_process(delta):
	if not player_ref:
		return

	# Move directly toward the player, no minimum distance check
	var direction = (player_ref.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Flip sprite to face the player
	if direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x < 0
