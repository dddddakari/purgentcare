extends Node

var good_points := 0:
	set(value):
		print("GameState: Good points changed from %d to %d" % [good_points, value])
		good_points = value

var bad_points := 0:
	set(value):
		print("GameState: Bad points changed from %d to %d" % [bad_points, value])
		bad_points = value
