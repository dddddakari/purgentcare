extends Area2D

@export_node_path("CanvasLayer") var dialogue_player_path: NodePath = "../Dialogue"
var dialogue_player: CanvasLayer

@onready var zombies = [
	get_node("../HostileZombies"),
	get_node("../HostileZombies2"),
	get_node("../HostileZombies3")
]

func _ready():
	if dialogue_player_path != NodePath():
		dialogue_player = get_node_or_null(dialogue_player_path)
		if dialogue_player and dialogue_player.has_signal("start_combat"):
			dialogue_player.start_combat.connect(_on_start_combat)
		else:
			push_warning("DialoguePlayer not found or signal missing at %s" % dialogue_player_path)

func _on_start_combat():
	print("Action: Starting combat")
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_player_attackable"):
		player.set_player_attackable(true)
		print("Player set to attackable")

	for z in zombies:
		if z and z.has_method("set_hostile"):
			z.set_hostile(true)
			print("Activated:", z.name)
		else:
			print("Failed to activate:", z)
