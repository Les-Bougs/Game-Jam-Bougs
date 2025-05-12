extends Control

@onready var orders_container = $MarginContainer/HBoxContainer
@export_enum("Inbound", "Outbound") var zone_type: String = "Inbound"

var order_scene = preload("res://scenes/order.tscn")
var orders = []
var initial_orders = {}

signal order_completed

func _ready():
	load_initial_orders("order_0")
	initialize_orders()
	if zone_type == 'Outbound':
		for order in orders:
			order.count = 0
			order.update_display()

func load_initial_orders(order_nb):
	var file = FileAccess.open("res://scripts/object_utils/initial_orders.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		initial_orders = JSON.parse_string(content)[order_nb]

func initialize_orders():
	for type in initial_orders:
		add_order(type, initial_orders[type])

func add_order(shape_type: String, count: int):
	var order_instance = order_scene.instantiate()
	order_instance.setup(shape_type, count)
	order_instance.order_completed.connect(_on_order_completed)
	orders_container.add_child(order_instance)
	orders.append(order_instance)

func clear_orders():
	for order in orders:
		order.queue_free()
	orders.clear()

# Vérification des commandes
func check_order(shape_type: String) -> bool:
	for order in orders:
		if not order.is_completed() and order.get_shape_type() == shape_type:
			if order.check_order():
				emit_signal("order_completed")
				return true
	return false

func is_all_completed() -> bool:
	for order in orders:
		if not order.is_completed():
			return false
	return true

func get_accepted_types() -> Array:
	var types = []
	for order in orders:
		if not order.is_completed():
			types.append(order.get_shape_type())
	return types

func _on_order_completed():
	emit_signal("order_completed") 
