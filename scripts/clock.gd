extends Node2D


@onready var clock_label: Label = $ClockLabel
@onready var timer: Timer = $Timer

@export var time_step = 0.1 # Temps (en s) entre chaque tick de l'horloge

@export var incr = 7 # Incrémentation de l'heure en minutes
@export var hours = 0 # Heure de départ
@export var minutes = 0 # Minutes de départ
@export var time_stop = 2 # Heure de fin

signal clock_timeout # Signal quand l'horloge atteint l'heure de fin

# Variables pour l'affichage de l'heure
var min_str = "00"
var hour_str = "00"

# Variable pour le clignotement de l'horloge
var blink_speed = 4.0 # Plus grand = clignote plus vite
var time_passed = 0.0


func _ready() -> void:
	# Initialisation de l'horloge avec le bon step
	timer.wait_time = time_step


func _process(delta: float) -> void:

	if minutes < 10:
		# Affiche un 0 devant les minutes
		min_str = "0" + str(minutes)
	else:
		min_str = str(minutes)
		
	if hours < 10:
		# Affiche un 0 devant les heures
		hour_str = "0" + str(hours)
	else:
		hour_str = str(hours)

	# Affichage de l'heure
	clock_label.text = hour_str + " " + min_str
		
	# L'horloge arrive à l'heure de fin
	if hours == time_stop:
		stop_clock()
		minutes = 0

		# Clignotement de l'horloge
		time_passed += delta * blink_speed
		var alpha = abs(sin(time_passed)) # oscille entre 0 et 1
		clock_label.modulate.a = alpha

		# Envoi du signal de timeout
		emit_signal("clock_timeout")
		

# Fonction pour démarrer l'horloge
func start_clock() -> void:
	timer.start()


# Fonction pour arrêter l'horloge
func stop_clock() -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	# Incrémentation de l'heure
	minutes += incr
	
	# Si on dépasse 59 minutes, on incrémente les heures
	if minutes > 59:
		minutes += -60
		hours +=1
	if hours > 23:
		hours = 0

	# Redémarre le timer
	timer.start()
