extends Node2D


@onready var black_screen: ColorRect = $BlackScreen
@onready var work_button: Button = $WorkButton


func _ready() -> void:
	black_screen.fade_out()



func _on_work_button_pressed() -> void:
	work_button.disabled = 1
	await black_screen.fade_in()
	get_tree().change_scene_to_file("res://scenes/workshop_level.tscn")
