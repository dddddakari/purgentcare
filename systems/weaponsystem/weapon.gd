extends Node
# Weapon properties
class_name Weapon

@export var weapon_name: String  
@export var weapon_atk: int
@export var texture: Texture2D  

# Static constructor function
static func create(w_name: String, w_atk: int, w_texture: Texture2D) -> Weapon:
	var weapon = Weapon.new()
	weapon.name = w_name
	weapon.atk = w_atk
	weapon.texture = w_texture
	return weapon
