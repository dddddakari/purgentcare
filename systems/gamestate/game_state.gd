extends Node

func _ready():
	if GameState == null:
		push_error("GameState singleton not found!")
	else:
		print("GameState found:", GameState)
	

var _good_points := 0

var good_points:
	get:
		return _good_points
	set(value):
		print("GameState: Good points changed from %d to %d" % [_good_points, value])
		_good_points = value

var _bad_points := 0

var bad_points:
	get:
		return _bad_points
	set(value):
		print("GameState: Bad points changed from %d to %d" % [_bad_points, value])
		_bad_points = value
