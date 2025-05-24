extends Node2D


@onready var black_screen: ColorRect = $BlackScreen
@onready var work_button: Button = $WorkButton


func _ready() -> void:
	black_screen.fade_out()
	var dialog_line = "day_" + str(Globals.day_nb) + "_pause_cafe"
	print(dialog_line)
	DialogueManager.show_dialogue_balloon(load("res://dialogues/dialogue_jeu_v1.dialogue"), dialog_line)



func _on_work_button_pressed() -> void:
	work_button.disabled = 1
	await black_screen.fade_in()
	get_tree().change_scene_to_file("res://scenes/workshop_level.tscn")
