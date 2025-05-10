extends Node2D

@onready var star_platform = $StarPlatform
@onready var validate_orders_button = $ValidateOrdersButton
@onready var star_counter_label = $StarCounterUI
@onready var timer_label = $TimerUI
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var restart_button = $GameOverPanel/RestartButton
@onready var center_panel = $CenterPanel

@export var time_max: float = 20
var time_left: float = time_max
var timer_active: bool = true
var current_score = 0

# Positions initiales des objets spawnables
var spawnable_positions = {
	"Rectangle": Vector2(960, 768),
	"Circle": Vector2(256, 768),
	"Triangle": Vector2(616, 768)
}

func _ready():
	# Connecter les signaux
	if star_platform:
		star_platform.order_count_changed.connect(_on_order_count_changed)
	
	validate_orders_button.pressed.connect(_on_validate_orders_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	game_over_panel.hide()
	
	# Initialiser le compteur
	star_counter_label.text = "Orders: 0"

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
	final_score_label.text = "Final Score: %d Orders" % current_score
	
	global.is_dragging = false
	
	center_panel.modulate = Color(0.5, 0.5, 0.5, 1)
	$RightPanel.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_order_count_changed(count: int):
	current_score = count
	star_counter_label.text = "Orders: " + str(current_score)

func _on_restart_button_pressed():
	time_left = time_max
	timer_active = true
	current_score = 0
	star_counter_label.text = "Orders: 0"
	
	game_over_panel.hide()
	
	center_panel.modulate = Color(1, 1, 1, 1)
	$RightPanel.modulate = Color(1, 1, 1, 1)
	
	# Nettoyer les objets existants
	for obj in get_tree().get_nodes_in_group("draggable"):
		obj.queue_free()
	
	# Nettoyer les zones de dépôt
	for platform in get_tree().get_nodes_in_group("dropable"):
		platform.contained_objects.clear()
		if platform.zone_type == "StarCollector":
			platform.validated_objects.clear()  # Réinitialiser la liste des étoiles validées
		platform.update_label()
		# Forcer une mise à jour du compteur d'étoiles
		if platform == star_platform and platform.has_method("update_star_counter"):
			platform.update_star_counter()
	
	# Recréer les objets spawnables
	var object_factory = get_node("/root/ObjectFactory")
	for type in spawnable_positions:
		var position = spawnable_positions[type]
		object_factory.spawn_in_pile(type, position, Vector2(0.5, 0.5), center_panel)

func _on_validate_orders_button_pressed():
	star_platform.validate_orders() 
