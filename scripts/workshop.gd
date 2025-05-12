extends Node2D

@onready var validate_orders_button = $Validate
@onready var order_platform: StaticBody2D = $ZoneFinal
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var restart_button = $GameOverPanel/RestartButton
@onready var clock: Node2D = $Clock

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
	game_over_panel.hide()
	
  	# load orders from json
	load_orders(global.day_nb)
	update_counter_display()
	
  	# setup clock ui
	clock.set_alarm(12)
	clock.start_clock()

	
	# Connecter le signal de validation des formes à la scène Order
	if order_platform.has_method("validate_orders"):
		order_platform.order_validated.connect(_on_shape_validated)


func load_orders(day_nb: int):
	var order_name = 'order_' + str(day_nb)
	print(order_name)
	var list_in = get_node("ListOrderIn")
	var list_out = get_node("ListOrderOut")
	
	if list_in:
		list_in.clear_orders()
		list_in.load_initial_orders(order_name)
		list_in.initialize_orders()
		
		if list_out:
			list_out.clear_orders()
			for type in list_in.initial_orders:
				list_out.add_order(type, 0)


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
			final_score_label.text = "Order Completed !"
			show_completion_message()

func show_completion_message():
	clock.stop_clock()
	game_over_panel.show()
	#final_score_label.text = "Order Completed !"
	
	# Désactiver les interactions pendant le game over
	validate_orders_button.disabled = true
	order_platform.set_process(false)

func _on_restart_button_pressed():
	global.day_nb += 1
	get_tree().reload_current_scene()

func update_counter_display():
	var display_text = "Orders:\n"
	for type in order_counts:
		display_text += "%s: %d\n" % [type, order_counts[type]]

func _on_validate_orders_button_pressed():
	if order_platform.has_method("validate_orders"):
		var new_orders = order_platform.validate_orders()

func _on_clock_clock_timeout() -> void:
	# Vérifier si la commande est complétée
	var list_order = get_node("ListOrderIn")
	var list_order_out = get_node("ListOrderOut")
	
	if list_order and list_order.is_all_completed():
		final_score_label.text = "Order Completed !"
	else:
		final_score_label.text = "Order Not Completed !"
	show_completion_message()


func _input(event):
	if event.is_action_pressed("validate_key"):
		if game_over_panel.visible:
			_on_restart_button_pressed()
		else:
			_on_validate_orders_button_pressed()