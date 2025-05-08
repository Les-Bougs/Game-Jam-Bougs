extends Node2D

@export_enum("Rectangle", "Circle", "Triangle", "Star", "Hexagon") var object_type: String = "Rectangle"
@export var spawnable: bool = false

var pilePos: Vector2
var startPos: Vector2
var initialScale: Vector2

var draggable = false
var is_inside_dropable = false
var current_dropable = null
var offset: Vector2
var initialPos: Vector2

# Références aux gestionnaires
var object_factory: Node
var object_combiner: Node

func _ready():
	pilePos = position
	initialScale = scale
	add_to_group("draggable")
	$AnimatedSprite2D.frame = get_frame_id(object_type)
	
	# Récupère les références aux gestionnaires
	object_factory = get_node("/root/ObjectFactory")
	object_combiner = get_node("/root/ObjectCombiner")
	
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

###########
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
		object_factory.spawn_in_pile(object_type, pilePos, initialScale, get_parent())

func return_to_initial_position(tween):
	tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
	if current_dropable != null:
		current_dropable.remove_object(self)
		current_dropable = null
		is_inside_dropable = false

func check_combinations():
	for obj in get_tree().get_nodes_in_group("draggable"):
		if obj != self and obj.current_dropable == current_dropable:
			object_combiner.try_combine(self, obj, current_dropable)
			break

func _on_area_2d_mouse_entered() -> void:
	#print('entered')
	if not global.is_dragging:
		draggable = true
		scale = initialScale * 1.05

func _on_area_2d_mouse_exited() -> void:
	#print('exited')
	if not global.is_dragging:
		draggable = false
		scale = initialScale

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
