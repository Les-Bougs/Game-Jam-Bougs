extends PanelContainer

@onready var sprite_wrapper: Control = $MarginContainer/SpriteWrapper
@onready var animated_sprite: AnimatedSprite2D = sprite_wrapper.get_node("AnimatedSprite2D")
@onready var count_label: Label = $MarginContainer/CountLabel

var shape_type: String = "CircuitBoard"
var count: int = 5
var frame_ids = {}
var is_outbound = false

signal order_completed

func _ready():
	sprite_wrapper.custom_minimum_size = Vector2.ZERO
	if is_outbound == "Outbound":
		count_label.custom_minimum_size = Vector2.ZERO
		self.custom_minimum_size = Vector2(50,50)

		$MarginContainer.add_theme_constant_override("margin_left", 0)
		$MarginContainer.add_theme_constant_override("margin_top", 0)
		$MarginContainer.add_theme_constant_override("margin_right", 0)
		$MarginContainer.add_theme_constant_override("margin_bottom", 0)

	load_frame_ids()
	call_deferred("update_display")

func _process(_delta):
	resize_sprite()

func resize_sprite():
	var container_size = sprite_wrapper.size

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		var tex = animated_sprite.sprite_frames.get_frame_texture("default", get_frame_id(shape_type))
		if tex:
			var texture_size = tex.get_size()
			var scale_x = container_size.x / texture_size.x
			var scale_y = container_size.y / texture_size.y
			#var uniform_scale = min(scale_x, scale_y)
			animated_sprite.scale = Vector2(scale_x, scale_y)
			animated_sprite.position = container_size / 2
			animated_sprite.centered = true

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
	if not is_instance_valid(animated_sprite) or not is_instance_valid(count_label):
		return

	animated_sprite.animation = "default"
	animated_sprite.frame = get_frame_id(shape_type)

	count_label.text = "x%d" % count

func get_frame_id(object_type: String) -> int:
	return frame_ids.get(object_type, 0)  # 0 = frame fallback

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
