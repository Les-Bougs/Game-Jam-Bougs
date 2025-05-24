extends Node2D


@onready var sleep_button: Button = $Bed/SleepButton
@onready var black_screen: ColorRect = $BlackScreen
@onready var black_screen_label: Label = $BlackScreen/BlackScreenLabel
@onready var timer: Timer = $Timer
@onready var game_over_panel: Panel = $GameOverPanel
@onready var restart_button: Button = $GameOverPanel/RestartButton
@onready var final_score_label: Label = $GameOverPanel/FinalScoreLabel


func _ready() -> void:
	sleep_button.hide()
	black_screen_label.text = ""
	game_over_panel.hide()
	restart_button.pressed.connect(_on_restart_button_pressed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	await black_screen.fade_out()
	
	var dialogue = load("res://dialogues/dialogue_jeu_v1.dialogue")
	
	# Afficher le dialogue du soir
	var dialogue_name = "day_" + str(Globals.day_nb) + "_evening"
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_name)
	

func _on_dialogue_ended(dialogue_resource) -> void:
	print("is game over : ", Globals.game_over)
	if Globals.game_over:
		final_score_label.text = "Tu as tenu " + str(Globals.day_nb) + " jours"
		game_over_panel.show()
		return
	


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


func _on_restart_button_pressed() -> void:
	# Réinitialiser toutes les variables globales
	Globals.is_dragging = false
	Globals.day_nb = 0
	Globals.level_state = "afternoon"
	Globals.player_money = 0
	Globals.tuto = false
	Globals.first_pick = true
	Globals.first_drop = true
	Globals.first_send = true
	Globals.first_day = true
	Globals.game_over = false
	
	# Retourner à la scène de l'atelier
	get_tree().change_scene_to_file("res://scenes/workshop_level.tscn")
