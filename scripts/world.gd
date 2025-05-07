extends Node2D

@onready var star_counter_label = $StarCounterUI
@onready var timer_label = $TimerUI
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var restart_button = $GameOverPanel/RestartButton

@export var time_max: float = 20
var time_left: float = time_max
var timer_active: bool = true
var current_score: int = 0

func _ready():
	var star_platform = $CenterPanel/star_platform
	star_platform.star_count_changed.connect(_on_star_count_changed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	game_over_panel.hide()

func _process(delta):
	if timer_active:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			timer_active = false
			game_over()
		update_timer_display()

func update_timer_display():
	var seconds = int(time_left)
	timer_label.text = "Time Left: %d" % seconds

func game_over():
	game_over_panel.show()
	final_score_label.text = "Final Score: %d Stars" % current_score
	
	global.is_dragging = false
	
	$CenterPanel.modulate = Color(0.5, 0.5, 0.5, 1)
	$LeftPanel.modulate = Color(0.5, 0.5, 0.5, 1)
	$RightPanel.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_star_count_changed(count: int):
	current_score = count
	star_counter_label.text = "Stars: " + str(count)

func _on_restart_button_pressed():
	time_left = time_max
	timer_active = true
	current_score = 0
	star_counter_label.text = "Stars: 0"
	
	game_over_panel.hide()
	
	$CenterPanel.modulate = Color(1, 1, 1, 1)
	$LeftPanel.modulate = Color(1, 1, 1, 1)
	$RightPanel.modulate = Color(1, 1, 1, 1)
	
	for obj in get_tree().get_nodes_in_group("draggable"):
		obj.queue_free()
	
	for platform in get_tree().get_nodes_in_group("dropable"):
		platform.contained_objects.clear()
		platform.update_label() 
