# Create this as an AutoLoad (only if it no worky on your machine Maxim)
extends Node

# Dictionary to store quest items
var quest_items: Dictionary = {}
var path_chosen: String = ""  # "good", "bad", or ""
var cabinet_knocked: bool = false
var letter_used: bool = false
var nurse_left_to_find_janitor: bool = false


# Signal for when quest items are added/removed
signal quest_item_added(item_name: String)
signal quest_item_removed(item_name: String)

func add_quest_item(item_name: String) -> void:
	quest_items[item_name] = true
	quest_item_added.emit(item_name)
	print("Quest item added: ", item_name)

func remove_quest_item(item_name: String) -> void:
	if quest_items.has(item_name):
		quest_items.erase(item_name)
		quest_item_removed.emit(item_name)
		print("Quest item removed: ", item_name)

func has_quest_item(item_name: String) -> bool:
	return quest_items.has(item_name)

func get_all_quest_items() -> Array:
	return quest_items.keys()

func clear_all_quest_items() -> void:
	quest_items.clear()
	print("All quest items cleared")

# Save/Load functionality (optional)
func save_quest_data() -> Dictionary:
	return {"quest_items": quest_items}

func load_quest_data(data: Dictionary) -> void:
	if data.has("quest_items"):
		quest_items = data["quest_items"]
		
signal quest_progress(method: String)  # "good" or "bad"

# Add these new functions
func set_path_chosen(path: String):
	path_chosen = path
	print("Path chosen: ", path)

# Add these functions with your other functions
func set_cabinet_knocked():
	cabinet_knocked = true
	print("Cabinet has been knocked over")

func set_letter_used():
	letter_used = true
	print("Love letter has been used")

func can_use_letter() -> bool:
	return not letter_used  # Simplified - only check if letter was used

func can_knock_cabinet() -> bool:
	return not cabinet_knocked and not letter_used  # Can't knock if letter was used

func set_nurse_left():
	nurse_left_to_find_janitor = true
	print("Nurse has left to find janitor")
	
func can_open_file_room() -> bool:
	return has_quest_item("file_room_key")

func complete_quest_good():
	print("QuestManager: Completing quest via GOOD path")
	set_path_chosen("good")  # Set the path when completing quest
	quest_progress.emit("good")
	GameState.good_points += 1
	print("Current good points: %d, bad points: %d" % [GameState.good_points, GameState.bad_points])

func complete_quest_bad():
	print("QuestManager: Completing quest via BAD path")
	set_path_chosen("bad")  # Set the path when completing quest
	quest_progress.emit("bad")
	GameState.bad_points += 1
	print("Current good points: %d, bad points: %d" % [GameState.good_points, GameState.bad_points])
