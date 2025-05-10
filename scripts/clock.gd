extends Node2D


@onready var clock_label: Label = $ClockLabel
@onready var timer: Timer = $Timer

@export var time_step = 0.1
@export var incr = 7
@export var hours = 0
@export var minutes = 0
@export var time_stop = 2

signal clock_timeout

var min_str = "00"
var hour_str = "00"
var clock_on = 0

var blink_speed = 4.0 # Plus grand = clignote plus vite
var time_passed = 0.0


func _ready() -> void:
	timer.wait_time = time_step


func _process(delta: float) -> void:
	if minutes < 10:
		min_str = "0" + str(minutes)
	else:
		min_str = str(minutes)
		
	if hours < 10:
		hour_str = "0" + str(hours)
	else:
		hour_str = str(hours)
	clock_label.text = hour_str + " " + min_str
	
	if clock_on and timer.is_stopped():
		timer.start()
	elif !clock_on:
		timer.stop()
		
	if hours == time_stop:
		minutes = 0
		clock_on = 0
		time_passed += delta * blink_speed
		var alpha = abs(sin(time_passed)) # oscille entre 0 et 1
		clock_label.modulate.a = alpha
		emit_signal("clock_timeout")
		
	if Input.is_action_just_pressed("ui_accept"):
		clock_on = !clock_on


func _on_timer_timeout() -> void:
	minutes += incr
	
	if minutes > 59:
		minutes += -60
		hours +=1
	if hours > 23:
		hours = 0
		
	timer.start()
