extends Control

@onready var orders_container = $MarginContainer/HBoxContainer

var order_scene = preload("res://scenes/order.tscn")
var orders = []

signal order_completed

func _ready():
	initialize_orders()

# Configuration initiale des commandes
func initialize_orders():
	add_order("Star", 2)
	add_order("Hexagon", 1)
	add_order("Circle", 1)

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
