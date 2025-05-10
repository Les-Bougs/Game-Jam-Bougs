extends Control

var fade_time := 0.7

func _ready():
	$StartButton.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	var tween = create_tween()
	tween.tween_property($Background, "modulate:a", 0.0, fade_time)
	tween.tween_callback(Callable(self, "_go_to_workshop"))

func _go_to_workshop():
	get_tree().change_scene_to_file("res://scenes/workshop_level.tscn") 
