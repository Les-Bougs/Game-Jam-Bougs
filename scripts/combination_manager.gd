extends Node

var combination_data = {}

func _ready():
	load_combinations()

func load_combinations():
	var file = FileAccess.open("res://scripts/combinations.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		combination_data = JSON.parse_string(content)

func can_combine(type1: String, type2: String) -> bool:
	var types = [type1, type2]
	types.sort()
	var combo_key = types[0] + "+" + types[1]
	return combo_key in combination_data

func get_combination_result(type1: String, type2: String) -> String:
	var types = [type1, type2]
	types.sort()
	var combo_key = types[0] + "+" + types[1]
	return combination_data[combo_key] if combo_key in combination_data else "" 
