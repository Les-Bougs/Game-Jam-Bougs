extends Node2D

@export_enum("Rectangle", "Circle", "Triangle", "Star", "Face") var shape_type: String = "Rectangle"
@export var spawnable: bool = false

var source_scene: String
var draggable = false
var is_inside_dropable = false
var current_dropable = null
var offset: Vector2
var initialPos: Vector2
var pilePos: Vector2
var startPos: Vector2

func _ready():
	source_scene = "res://scenes/" + shape_type + ".tscn"
	pilePos = position
	add_to_group("draggable")

func _process(delta):
	if not draggable:
		return
		
	if Input.is_action_just_pressed("click"):
		start_drag()
	elif Input.is_action_pressed("click"):
		update_drag()
	elif Input.is_action_just_released("click"):
		end_drag()

func start_drag():
	startPos = position
	initialPos = global_position
	offset = get_global_mouse_position() - global_position
	global.is_dragging = true

func update_drag():
	global_position = get_global_mouse_position() - offset

func end_drag():
	global.is_dragging = false
	var tween = get_tree().create_tween()
	
	if is_inside_dropable and current_dropable.is_valid_placement(self):
		place_in_zone(tween)
	else:
		return_to_initial_position(tween)

func place_in_zone(tween):
	tween.tween_property(self, "position", current_dropable.position, 0.2).set_ease(Tween.EASE_OUT)
	check_combinations()
	if startPos == pilePos and spawnable:
		spawn_new_instance()

func return_to_initial_position(tween):
	tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
	if current_dropable != null:
		current_dropable.remove_object(self)
		current_dropable = null
		is_inside_dropable = false

func check_combinations():
	var combination_manager = get_node("/root/CombinationManager")
	for obj in get_tree().get_nodes_in_group("draggable"):
		if obj != self and obj.current_dropable == current_dropable:
			if combination_manager.can_combine(self.shape_type, obj.shape_type):
				var result_type = combination_manager.get_combination_result(self.shape_type, obj.shape_type)
				create_combination_result(result_type)
				current_dropable.remove_object(self)
				current_dropable.remove_object(obj)
				self.queue_free()
				obj.queue_free()
				break

func create_combination_result(result_type: String):
	print("Fusion réussie : ", shape_type, " + ", result_type)
	var result_scene = load("res://scenes/%s.tscn" % result_type)
	if result_scene:
		var new_object = result_scene.instantiate()
		new_object.position = current_dropable.position
		get_parent().add_child(new_object)

func spawn_new_instance():
	var scene = load(source_scene)
	if scene:
		var new_instance = scene.instantiate()
		new_instance.global_position = pilePos
		get_parent().add_child(new_instance)
		print("Nouvelle instance créée : ", shape_type)

func _on_area_2d_mouse_entered() -> void:
	if not global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	if not global.is_dragging:
		draggable = false
		scale = Vector2(1.0, 1.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group('dropable'):
		return
		
	if current_dropable != null and current_dropable != body:
		current_dropable.remove_object(self)
		current_dropable.modulate = Color(Color.MEDIUM_PURPLE, 1)
	
	if body.is_valid_placement(self):
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body.add_object(self)
	else:
		body.modulate = Color(Color.RED, 1)
	
	is_inside_dropable = true
	current_dropable = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable') and body == current_dropable:
		is_inside_dropable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 1)
		body.remove_object(self)
		current_dropable = null

func _exit_tree():
	if current_dropable != null and is_instance_valid(current_dropable):
		current_dropable.remove_object(self)
		current_dropable = null
