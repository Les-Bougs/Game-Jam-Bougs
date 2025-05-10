extends PanelContainer

@onready var texture_rect = $MarginContainer/VBoxContainer/TextureRect
@onready var count_label = $MarginContainer/VBoxContainer/CountLabel

var shape_type: String = "Star"
var count: int = 5

var shape_textures = {
	"Star": preload("res://assets/Star.png"),
	"Hexagon": preload("res://assets/Hexagon.png"),
	"Circle": preload("res://assets/Circle.png")
}

func _ready():
	call_deferred("update_display")

func setup(type: String, initial_count: int):
	shape_type = type
	count = initial_count
	call_deferred("update_display")

func update_display():
	if not is_instance_valid(texture_rect) or not is_instance_valid(count_label):
		return
		
	if shape_type in shape_textures:
		texture_rect.texture = shape_textures[shape_type]
	count_label.text = "x%d" % count

func check_order() -> bool:
	if count > 0:
		count -= 1
		call_deferred("update_display")
		return true
	return false

func is_completed() -> bool:
	return count <= 0

func get_shape_type() -> String:
	return shape_type

signal order_completed 
