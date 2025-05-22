extends Node2D

@export_enum("Plank", "Hammer", "Nail", "NailPlank", "Furniture") var object_type: String = "Plank"
@export var spawnable: bool = false

var pilePos: Vector2
var startPos: Vector2
var initialScale: Vector2
var frame_ids = {}

var draggable = false
var is_inside_dropable = false
var current_dropable = null
var offset: Vector2
var initialPos: Vector2

var object_factory: Node
var object_combiner: Node

func _ready():
	load_frame_ids()
	pilePos = position
	initialScale = scale
	add_to_group("draggable")
	$AnimatedSprite2D.frame = get_frame_id(object_type)
	object_factory = get_node("/root/ObjectFactory")
	object_combiner = get_node("/root/ObjectCombiner")

func load_frame_ids():
	var file = FileAccess.open("res://scripts/object_utils/frame_ids.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		frame_ids = JSON.parse_string(content)

func get_frame_id(object_type):
	return frame_ids.get(object_type, 5)

func _physics_process(_delta: float) -> void:
	if not draggable:
		return
		
	if Input.is_action_just_pressed("click"):
		start_drag()
		z_index += 1
	elif Input.is_action_pressed("click"):
		update_drag()
	elif Input.is_action_just_released("click"):
		await end_drag()
		z_index -= 1

func start_drag():
	startPos = position
	initialPos = global_position
	offset = get_global_mouse_position() - global_position
	Globals.is_dragging = true
	if Globals.first_pick:
		var dialogue_name = "day_" + str(Globals.day_nb) + "_" + Globals.level_state + "_first_pick"
		DialogueManager.show_dialogue_balloon(load("res://dialog_test.dialogue"), dialogue_name)
		Globals.first_pick = false

func update_drag():
	global_position = get_global_mouse_position() - offset

func end_drag():
	Globals.is_dragging = false
	var tween = get_tree().create_tween()
	
	if is_inside_dropable and current_dropable.is_valid_placement(self):
		await place_in_zone(tween)
		if Globals.first_drop:
			var dialogue_name = "day_" + str(Globals.day_nb) + "_" + Globals.level_state + "_first_drop"
			DialogueManager.show_dialogue_balloon(load("res://dialog_test.dialogue"), dialogue_name)
			Globals.first_drop = false
	else:
		await return_to_initial_position(tween)

func place_in_zone(tween):
	tween.tween_property(self, "position", current_dropable.position, 0.2).set_ease(Tween.EASE_OUT)
	await tween.finished

	if current_dropable.zone_type == "Trash":
		if spawnable and startPos == pilePos:
			object_factory.spawn_in_pile(object_type, pilePos, initialScale, get_parent())
		queue_free()
		return

	check_combinations()
	if startPos == pilePos and spawnable:
		object_factory.spawn_in_pile(object_type, pilePos, initialScale, get_parent())

func return_to_initial_position(tween):
	tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
	await tween.finished
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
	if not Globals.is_dragging:
		draggable = true
		scale = initialScale * 1.05

func _on_area_2d_mouse_exited() -> void:
	if not Globals.is_dragging:
		draggable = false
		scale = initialScale

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("dropable"):
		return

	if current_dropable != null and current_dropable != body:
		current_dropable.remove_object(self)
		tween_modulate(current_dropable, Color(1, 1, 1, 0.5))
		for obj in current_dropable.get_contained_objects():
			if obj != self:
				tween_modulate(obj, Color(1, 1, 1, 1))

	if body.is_valid_placement(self):
		tween_modulate(body, Color(0, 1, 0, 0.7)) # vert
		body.add_object(self)
		for obj in body.get_contained_objects():
			if obj != self:
				tween_modulate(obj, Color(0, 1, 0, 0.7))
	else:
		tween_modulate(body, Color(1, 0, 0, 0.7)) # rouge
		for obj in body.get_contained_objects():
			if obj != self:
				tween_modulate(obj, Color(1, 0, 0, 0.7))

	is_inside_dropable = true
	current_dropable = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("dropable") and body == current_dropable:
		is_inside_dropable = false
		tween_modulate(body, Color(1, 1, 1, 0.5))
		for obj in body.get_contained_objects():
			if obj != self:
				tween_modulate(obj, Color(1, 1, 1, 1))
		body.remove_object(self)
		current_dropable = null

func tween_modulate(target: Node, color: Color):
	if not is_instance_valid(target):
		return
	var tween = get_tree().create_tween()
	tween.tween_property(target, "modulate", color, 0.08) # <== accéléré

func _exit_tree():
	if current_dropable != null and is_instance_valid(current_dropable):
		current_dropable.remove_object(self)
		current_dropable = null
