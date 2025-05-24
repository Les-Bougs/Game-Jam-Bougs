extends Node2D

@onready var validate_orders_button = $Validate
@onready var order_platform: StaticBody2D = $ZoneFinal
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var clock: Node2D = $Clock
@onready var black_screen: ColorRect = $BlackScreen
@onready var npc = $NPC

var order_counts = {
	"CircuitBoard": 0,
	"TransistorModule": 0,
	"ComputerUnit": 0
}

var inventory = {
	"CircuitBoard": 0,
	"TransistorModule": 0,
	"ComputerUnit": 0
}

# Positions initiales des objets spawnables
var spawnable_positions = {
	"CircuitBoard": Vector2(232, 768),
	"SolderingIron": Vector2(552, 768),
	"TransistorModule": Vector2(872, 768),
	"ComputerUnit": Vector2(1192, 768)
}

func _ready():
	npc.hide()
	print("old : " ,Globals.day_nb, ' ', Globals.level_state)
	if Globals.level_state == 'afternoon':
		Globals.day_nb +=1
		Globals.level_state = 'morning'
	else:
		Globals.level_state = 'afternoon'
		
	print("new : ",Globals.day_nb, ' ', Globals.level_state)
	game_over_panel.hide() # Hide the game over panel at the start
	
	# setup clock hours and alarm depending on the level state
	if Globals.level_state == "morning":
		clock.hours = 7
		clock.set_alarm(12)
	elif Globals.level_state == "afternoon":
		clock.hours = 13
		clock.set_alarm(18)
		
	
	validate_orders_button.pressed.connect(_on_validate_orders_button_pressed)

  	# load orders from json
	load_orders(Globals.day_nb)
	#update_counter_display()
	
	# Connecter le signal de validation des formes à la scène Order
	if order_platform.has_method("validate_orders"):
		order_platform.order_validated.connect(_on_shape_validated)

	# ecran noir de transition
	await black_screen.fade_out()
	var dialogue_name = "day_" + str(Globals.day_nb) + "_" + Globals.level_state
	DialogueManager.show_dialogue_balloon(load("res://dialogues/dialogue_jeu_v1.dialogue"), dialogue_name)
	Globals.first_day = false
	# Démarrer l'horloge
	clock.start_clock()

func load_orders(day_nb: int):
	var order_name = 'day_' + str(day_nb) + '_' + Globals.level_state
	print(order_name)
	var list_in = get_node("ListOrderIn")
	var list_out = get_node("ListOrderOut")
	
	if list_in:
		list_in.clear_orders()
		list_in.load_initial_orders(order_name)
		list_in.initialize_orders()
		
		if list_out:
			list_out.clear_orders()
			for order in list_in.initial_orders.orders:
				list_out.add_order(order.type, 0)


func _on_shape_validated(shape_type: String):
	if shape_type in order_counts:
		order_counts[shape_type] += 1
		
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
			Globals.player_money += 10
			show_completion_message()


func show_completion_message():
	clock.stop_clock()
	game_over_panel.show()
	
	# Désactiver les interactions pendant le game over
	validate_orders_button.disabled = true
	order_platform.set_process(false)


# Passer à la scène suivante
func _on_next_button_pressed() -> void:
	if Globals.level_state == "morning":
		await black_screen.fade_in()
		get_tree().change_scene_to_file("res://scenes/cafet_level.tscn")
	elif Globals.level_state == "afternoon":
		await black_screen.fade_in()
		get_tree().change_scene_to_file("res://scenes/home_level.tscn")


func _on_validate_orders_button_pressed():
	if order_platform.has_method("validate_orders"):
		order_platform.validate_orders()
	if Globals.first_send:
		var dialogue_name = "day_" + str(Globals.day_nb) + "_" + Globals.level_state + "_tuto_end"
		DialogueManager.show_dialogue_balloon(load("res://dialogues/dialogue_jeu_v1.dialogue"), dialogue_name)
		Globals.first_send = false


func _on_clock_clock_timeout() -> void:
	# Vérifier si la commande est complétée
	var list_order = get_node("ListOrderIn")
	
	if list_order and list_order.is_all_completed():
		final_score_label.text = "Order Completed !"
		Globals.player_money += 10
	else:
		final_score_label.text = "Order Not Completed !"
	show_completion_message()


func _input(event):
	if event.is_action_pressed("validate_key"):
		if game_over_panel.visible:
			_on_next_button_pressed()
		else:
			_on_validate_orders_button_pressed()
	elif event.is_action_pressed("cheat_day"):
		if game_over_panel.visible:
			_on_next_button_pressed()
		else:
			print("cheat_day")
			final_score_label.text = "Order Completed !"
			Globals.player_money += 10
			show_completion_message()
	
	# Raccourcis pour envoyer directement des éléments vers la zone de validation
	if not game_over_panel.visible:
		var object_mapping = {
			"send_object1": "Objects/Object1",
			"send_object2": "Objects/Object2",
			"send_object3": "Objects/Object3",
			"send_object4": "Objects/Object4",
			"send_object5": "Objects/Object5"
		}
		
		for action in object_mapping:
			if event.is_action_pressed(action):
				var source_obj = get_node(object_mapping[action])
				if source_obj and source_obj.is_inside_tree() and source_obj.spawnable:
					var new_obj = ObjectFactory.create_object(
						source_obj.object_type,
						order_platform.global_position,
						source_obj.scale,
						self
					)
					if new_obj:
						_on_validate_orders_button_pressed()
				break
