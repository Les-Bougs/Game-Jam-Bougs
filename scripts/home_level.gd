extends Node2D


@onready var sleep_button: Button = $Bed/SleepButton
@onready var black_screen: ColorRect = $BlackScreen
@onready var black_screen_label: Label = $BlackScreen/BlackScreenLabel
@onready var timer: Timer = $Timer


func _ready() -> void:
	sleep_button.hide()
	black_screen_label.text = ""
	await black_screen.fade_out()
	
	# Afficher le dialogue du soir
	var dialogue_name = "day_" + str(Globals.day_nb) + "_evening"
	DialogueManager.show_dialogue_balloon(load("res://dialog_test.dialogue"), dialogue_name)


func _on_bed_mouse_entered() -> void:
	sleep_button.show()


func _on_bed_mouse_exited() -> void:
	sleep_button.hide()


func _on_sleep_button_pressed() -> void:
	sleep_button.disabled = 1
	await black_screen.fade_in()
	
	for i in 3:
		black_screen_label.text = black_screen_label.text + "Z"
		await get_tree().create_timer(0.5).timeout
	for i in 3:
		black_screen_label.text = black_screen_label.text + "."
		await get_tree().create_timer(0.5).timeout
	
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/workshop_level.tscn")
