extends StaticBody2D

signal order_count_changed(count: int)
signal order_validated(shape_type: String)

@export_enum("Normal", "Collector", "Trash") var zone_type: String = "Normal"
@export var accepted_types: Array = []

var contained_objects = []
#@onready var label = $Label
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	add_to_group("dropable")
	sprite.frame = get_frame_id(zone_type)
	
	if zone_type == "Collector":
		update_accepted_types()
	elif zone_type == "Trash":
		modulate = Color(Color.RED, 0.7)

func _process(_delta: float) -> void:
	visible = Globals.is_dragging
	if zone_type == "Collector":
		update_accepted_types()
	update_label()

func update_accepted_types():
	var list_order = get_parent().get_node("ListOrderIn")
	if list_order and list_order.has_method("get_accepted_types"):
		accepted_types = list_order.get_accepted_types()

func validate_orders():
	if zone_type != "Collector":
		return 0
		
	var new_orders = 0
	for obj in contained_objects:
		if is_instance_valid(obj) and obj.object_type in accepted_types:
			var list_order = get_parent().get_node("ListOrderIn")
			if list_order and list_order.check_order(obj.object_type):
				new_orders += 1
				emit_signal("order_validated", obj.object_type)
				obj.queue_free()
	
	contained_objects.clear()
	update_label()
	return new_orders

func get_frame_id(zone_type: String) -> int:
	match zone_type:
		"Normal": return 0
		"Collector": return 0
		"Trash": return 11
		_: return 0

func add_object(obj):
	if obj not in contained_objects:
		contained_objects.append(obj)
		update_label()

func remove_object(obj):
	if obj in contained_objects:
		contained_objects.erase(obj)
		update_label()

func get_contained_objects():
	return contained_objects

func update_label():
	var shapes = []
	for obj in contained_objects:
		if is_instance_valid(obj):
			shapes.append(obj.object_type)
	#label.text = str(shapes)

func is_valid_placement(obj) -> bool:
	if zone_type == "Collector":
		return obj.object_type in accepted_types
	if zone_type == "Trash":
		return true
	# Zone normale
	print(obj.object_type)
	if contained_objects.size() == 0:
		return true
	for contained_obj in contained_objects:
		if contained_obj == obj:
			return true
		var combination_manager = get_node("/root/CombinationManager")
		if combination_manager.can_combine(contained_obj.object_type, obj.object_type):
			return true
	return false 
