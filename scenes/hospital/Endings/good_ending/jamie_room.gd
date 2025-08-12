extends Node2D

@onready var player: CharacterBody2D = $Player


@onready var jamies := [
	{
		"node": $Jamie,
		"hitbox_area": $Jamie/enemy_hitbox,
		"detect_area": $Jamie/detection_area,
		"hitbox_shape": $Jamie/enemy_hitbox/CollisionShape2D,
		"detect_shape": $Jamie/detection_area/CollisionShape2D
	},
	{
		"node": $Jamie2,
		"hitbox_area": $Jamie2/enemy_hitbox,
		"detect_area": $Jamie2/detection_area,
		"hitbox_shape": $Jamie2/enemy_hitbox/CollisionShape2D,
		"detect_shape": $Jamie2/detection_area/CollisionShape2D
	},
	{
		"node": $Jamie3,
		"hitbox_area": $Jamie3/enemy_hitbox,
		"detect_area": $Jamie3/detection_area,
		"hitbox_shape": $Jamie3/enemy_hitbox/CollisionShape2D,
		"detect_shape": $Jamie3/detection_area/CollisionShape2D
	}
]

var lebron_hostile = false   
var can_get_attacked = false

@export_node_path("CanvasLayer") var dialogue_player_path: NodePath = "Dialogue"
var dialogue_player : CanvasLayer

func _ready() -> void:
	_refresh_combat_state()
	
	if dialogue_player_path != NodePath():
		dialogue_player = get_node_or_null(dialogue_player_path)
		if dialogue_player and dialogue_player.has_signal("start_combat"):
			dialogue_player.start_combat.connect(_on_start_combat)
		else:
			push_warning("DialoguePlayer not found or signal missing at %s" % dialogue_player_path)

func set_lebron_hostile(state: bool):
	if lebron_hostile == state:
		return
	lebron_hostile = state
	_refresh_combat_state()

func _on_start_combat():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_player_attackable(true)
		set_lebron_hostile(true)

func _refresh_combat_state():
	for jamie in jamies:
		jamie["hitbox_area"].monitoring = lebron_hostile
		jamie["detect_area"].monitoring = lebron_hostile
		jamie["hitbox_shape"].disabled  = !lebron_hostile
		jamie["detect_shape"].disabled  = !lebron_hostile
		
