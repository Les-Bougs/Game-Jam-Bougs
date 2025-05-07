extends Node2D

var combination_data = {}

@export_enum("Rectangle", "Circle", "Triangle", "Star", "Face") var shape_type: String = "Rectangle"
@export var spawnable: bool = false
var source_scene: String
var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2
var pilePos: Vector2
var startPos: Vector2
var objects_in_same_dropable = []
var current_dropable = null

func _ready():
	source_scene = "res://scenes/" + shape_type + ".tscn"
	pilePos = position
	add_to_group("draggable")
	var file = FileAccess.open("res://scripts/combinations.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		combination_data = JSON.parse_string(content)

func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			startPos = position
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			global.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropable and is_valid_placement(body_ref):
				tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				check_other_shape()
				if startPos == pilePos and spawnable:
					print('new instance : ', shape_type)
					spawn_new_instance()
			else:
				tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
				# Si on relâche l'objet en dehors d'une zone ou dans une zone invalide, on s'assure qu'il est retiré de toutes les zones
				if current_dropable != null:
					current_dropable.remove_object(self)
					current_dropable = null
					is_inside_dropable = false
					objects_in_same_dropable.clear()

func check_other_shape():
	for obj in get_tree().get_nodes_in_group("draggable"):
		if obj != self and obj.current_dropable == body_ref:
			if obj not in objects_in_same_dropable:
				objects_in_same_dropable.append(obj)
				var types = [self.shape_type, obj.shape_type]
				types.sort()
				var combo_key = types[0] + "+" + types[1]
				if combo_key in combination_data:
					var result_scene_name = combination_data[combo_key]
					print("Fusion réussie : ", types[0], " + ", types[1], " = ", result_scene_name)
					var result_scene = load("res://scenes/%s.tscn" % result_scene_name)
					if result_scene:
						var new_object = result_scene.instantiate()
						new_object.position = body_ref.position
						get_parent().add_child(new_object)
						body_ref.remove_object(self)
						body_ref.remove_object(obj)
						self.queue_free()
						obj.queue_free()
						break

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
	if body.is_in_group('dropable'):
		# Si on entre dans une nouvelle zone, on s'assure d'être retiré de l'ancienne
		if current_dropable != null and current_dropable != body:
			current_dropable.remove_object(self)
			current_dropable.modulate = Color(Color.MEDIUM_PURPLE, 1)
		
		# On change la couleur en fonction de la validité du placement
		if is_valid_placement(body):
			body.modulate = Color(Color.REBECCA_PURPLE, 1)
			body.add_object(self)
		else:
			body.modulate = Color(Color.RED, 1)
		
		is_inside_dropable = true
		body_ref = body
		current_dropable = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		if body == current_dropable:
			is_inside_dropable = false
			body.modulate = Color(Color.MEDIUM_PURPLE, 1)
			body.remove_object(self)
			current_dropable = null
			objects_in_same_dropable.clear()

func _exit_tree():
	# Nettoyer la liste quand l'objet est détruit
	if current_dropable != null and is_instance_valid(current_dropable):
		current_dropable.remove_object(self)
		current_dropable = null
	objects_in_same_dropable.clear()

func is_valid_placement(dropable_body) -> bool:
	var objects_in_zone = dropable_body.get_contained_objects()
	
	# Si la zone est vide, le placement est toujours valide
	if objects_in_zone.size() == 0:
		return true
	
	# Si la zone contient des objets, on vérifie les conditions
	for obj in objects_in_zone:
		# Si on trouve un objet du même type, le placement est valide
		if obj.shape_type == self.shape_type:
			return true
		
		# Si on trouve un objet qui peut fusionner avec celui-ci, le placement est valide
		var types = [self.shape_type, obj.shape_type]
		types.sort()
		var combo_key = types[0] + "+" + types[1]
		if combo_key in combination_data:
			return true
	
	# Si aucune condition n'est remplie, le placement n'est pas valide
	return false
