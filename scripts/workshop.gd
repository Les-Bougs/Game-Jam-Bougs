extends Node2D

@onready var validate_orders_button = $Validate
@onready var order_platform: StaticBody2D = $ZoneFinal
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var restart_button = $GameOverPanel/RestartButton

var order_counts = {
	"Plank": 0,
	"NailPlank": 0,
	"Furniture": 0
}

# Positions initiales des objets spawnables
var spawnable_positions = {
	"Plank": Vector2(232, 768),
	"Hammer": Vector2(552, 768),
	"NailPlank": Vector2(872, 768),
	"Furniture": Vector2(1192, 768)
}

func _ready():
	validate_orders_button.pressed.connect(_on_validate_orders_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	update_counter_display()
	game_over_panel.hide()
	
	# Connecter le signal de validation des formes à la scène Order
	if order_platform.has_method("validate_orders"):
		order_platform.order_validated.connect(_on_shape_validated)

func _on_shape_validated(shape_type: String):
	if shape_type in order_counts:
		order_counts[shape_type] += 1
		update_counter_display()
		
		# Vérifier si la commande est complétée
		var list_order = get_node("ListOrderIn")
		var list_order_out = get_node("ListOrderOut")
		
		# Incrémenter le compteur dans ListOrderOut
		if list_order_out:
			for order in list_order_out.orders:
				if order.shape_type == shape_type:
					order.count += 1
					order.update_display()
		
		if list_order and list_order.is_all_completed():
			show_completion_message()

func show_completion_message():
	game_over_panel.show()
	final_score_label.text = "Order Completed !"
	
	# Désactiver les interactions pendant le game over
	validate_orders_button.disabled = true
	order_platform.set_process(false)

func _on_restart_button_pressed():
	# Réinitialiser les compteurs
	for type in order_counts:
		order_counts[type] = 0
	update_counter_display()
	
	# Réinitialiser la ListOrderIn
	var list_order = get_node("ListOrderIn")
	if list_order:
		list_order.clear_orders()
		list_order.add_order("Plank", 3)
		list_order.add_order("Furniture", 2)
		
	# Réinitialiser la ListOrderOut
	var list_order_out = get_node("ListOrderOut") 
	if list_order_out:
		list_order_out.clear_orders()
		list_order_out.add_order("Plank", 0)
		list_order_out.add_order("Furniture", 0)
	
	# Réactiver les interactions
	validate_orders_button.disabled = false
	order_platform.set_process(true)
	
	# Cacher le panel
	game_over_panel.hide()

func update_counter_display():
	var display_text = "Orders:\n"
	for type in order_counts:
		display_text += "%s: %d\n" % [type, order_counts[type]]

func _on_validate_orders_button_pressed():
	if order_platform.has_method("validate_orders"):
		var new_orders = order_platform.validate_orders()
