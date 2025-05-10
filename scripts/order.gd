extends PanelContainer

@onready var texture_rect = $MarginContainer/Control/TextureRect
@onready var count_label = $MarginContainer/Control/CountLabel

var shape_type: String = "Star"
var count: int = 5
var frame_ids = {}

signal order_completed

func _ready():
	load_frame_ids()
	call_deferred("update_display")

func load_frame_ids():
	var file = FileAccess.open("res://scripts/object_utils/frame_ids.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		frame_ids = JSON.parse_string(content)

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
	return frame_ids.get(object_type, 5)  # 5 est la valeur par défaut (Plank)

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
