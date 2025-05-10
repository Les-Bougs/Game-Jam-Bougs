extends PanelContainer

@onready var texture_rect = $MarginContainer/Control/TextureRect
@onready var count_label = $MarginContainer/Control/CountLabel

var shape_type: String = "Star"
var count: int = 5

signal order_completed

func _ready():
	call_deferred("update_display")

func setup(type: String, initial_count: int):
	shape_type = type
	count = initial_count
	call_deferred("update_display")

func update_display():
	if not is_instance_valid(texture_rect) or not is_instance_valid(count_label):
		return
		
	texture_rect.frame = get_frame_id(shape_type)
	count_label.text = "x%d" % count

func get_frame_id(object_type):
	match object_type:
		"Rectangle":
			return 0
		"Circle":
			return 1
		"Triangle":
			return 2
		"Star":
			return 3
		"Hexagon":
			return 4
		_:
			return 0

func check_order() -> bool:
	if count > 0:
		count -= 1
		call_deferred("update_display")
		if count == 0:
			emit_signal("order_completed")
		return true
	return false

func is_completed() -> bool:
	return count <= 0

func get_shape_type() -> String:
	return shape_type
