extends Control

@onready var order_container = $OrderContainer

var current_order: Dictionary = {
	"Star": 5,
	"Hexagon": 5
}

var shape_textures = {
	"Star": preload("res://assets/star.png"),
	"Hexagon": preload("res://assets/hexagon.png")
}

func _ready():
	if not order_container:
		push_error("OrderContainer non trouvé dans la scène!")
		return
		
	order_container.custom_minimum_size = Vector2(200, 100)
	order_container.alignment = BoxContainer.ALIGNMENT_CENTER
	update_order_display()
	print("Order initialisé avec les types : ", current_order.keys())  # Debug

func update_order_display():
	if not order_container:
		return
		
	# Nettoyer le conteneur existant
	for child in order_container.get_children():
		child.queue_free()
	
	# Créer un nouveau conteneur pour chaque forme
	for shape in current_order:
		var shape_container = HBoxContainer.new()
		shape_container.custom_minimum_size = Vector2(150, 40)
		shape_container.alignment = BoxContainer.ALIGNMENT_CENTER
		shape_container.add_theme_constant_override("separation", 10)
		
		# Ajouter l'image
		var texture_rect = TextureRect.new()
		texture_rect.texture = shape_textures[shape]
		texture_rect.custom_minimum_size = Vector2(32, 32)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Ajouter le texte
		var label = Label.new()
		label.text = "x%d" % current_order[shape]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		shape_container.add_child(texture_rect)
		shape_container.add_child(label)
		order_container.add_child(shape_container)

func check_order(shape_type: String) -> bool:
	if current_order.has(shape_type):
		current_order[shape_type] -= 1
		if current_order[shape_type] <= 0:
			current_order.erase(shape_type)
		
		update_order_display()
		print("Commande mise à jour : ", current_order)  # Debug
		return true
	
	return false

func is_order_completed() -> bool:
	return current_order.is_empty()

# Retourne la liste des types acceptés dans la commande
func get_accepted_types() -> Array:
	var types = current_order.keys()
	print("Types acceptés demandés : ", types)  # Debug
	return types

signal order_finished 
