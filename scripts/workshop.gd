extends Node2D

@onready var validate_orders_button = $Validate
@onready var order_platform = $ZoneFinal
@onready var order_counter_label = $OrderCounterUI
@onready var order_scene = $Order

var current_score: int = 0

# Positions initiales des objets spawnables
var spawnable_positions = {
	"Rectangle": Vector2(232, 768),
	"Circle": Vector2(552, 768),
	"Triangle": Vector2(872, 768),
	"Star": Vector2(1192, 768)
}

func _ready():
	validate_orders_button.pressed.connect(_on_validate_orders_button_pressed)
	order_counter_label.text = "Orders: 0"
	
	# Connecter le signal de validation des formes à la scène Order
	if order_platform.has_method("validate_orders"):
		order_platform.order_validated.connect(_on_shape_validated)

func _on_shape_validated(shape_type: String):
	print("Forme validée : ", shape_type)

func _on_validate_orders_button_pressed():
	if order_platform.has_method("validate_orders"):
		var new_orders = order_platform.validate_orders()
		current_score += new_orders
		order_counter_label.text = "Orders: " + str(current_score)
		
		# Générer une nouvelle commande après validation
		if order_scene and order_scene.has_method("generate_new_order"):
			order_scene.generate_new_order() 
