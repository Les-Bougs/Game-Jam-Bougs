extends Node

var combination_data = {}

func _ready():
	load_combinations()

func load_combinations():
	var file = FileAccess.open("res://scripts/object_utils/combinations.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		combination_data = JSON.parse_string(content)
		print("Loaded combination data: ", combination_data)

func can_combine(type1: String, type2: String) -> bool:
	var types = [type1, type2]
	types.sort()
	var combo_key = types[0] + "+" + types[1]
	var can_combine = combo_key in combination_data
	print("Checking combination for ", combo_key, ": ", can_combine)
	return can_combine

func get_combination_result(type1: String, type2: String) -> String:
	var types = [type1, type2]
	types.sort()
	var combo_key = types[0] + "+" + types[1]
	var result = combination_data[combo_key] if combo_key in combination_data else ""
	print("Combination result for ", combo_key, ": ", result)
	return result 
