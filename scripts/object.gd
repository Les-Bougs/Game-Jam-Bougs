extends Node2D

# Préchargez la scène "Object"
const GodotPnjScene = preload("res://scenes/face.tscn")
var combination_data = {}

@export_enum("Rectangle", "Circle", "Triangle", "Star", "Face") var shape_type: String = "Rectangle"

var is_dragging = false
var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2

# Liste pour garder une trace des autres objets dans la même zone dropable
var objects_in_same_dropable = []
var current_dropable = null

func _ready():
	add_to_group("draggable")
	var file = FileAccess.open("res://scripts/combinations.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		combination_data = JSON.parse_string(content)
		#print(combination_data)
	else:
		print("Erreur de chargement du fichier de combinaisons.")

func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			global.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropable:
				tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				check_other_shape()
				
			else:
				tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)

func check_other_shape():
	for obj in get_tree().get_nodes_in_group("draggable"):
		if obj != self and obj.current_dropable == body_ref:
			if obj not in objects_in_same_dropable:
				objects_in_same_dropable.append(obj)
				#print("fusion des objets: %s et %s" % [self.name, obj.name])

				var types = [self.shape_type, obj.shape_type]
				types.sort()
				var combo_key = types[0] + "+" + types[1]
				print(combo_key)

				if combo_key in combination_data:
					var result_scene_name = combination_data[combo_key]
					print(result_scene_name)
					var result_scene = load("res://scenes/%s.tscn" % result_scene_name)
					if result_scene:
						var new_object = result_scene.instantiate()
						new_object.position = body_ref.position
						get_parent().add_child(new_object)

						self.queue_free()
						obj.queue_free()
						break
					
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
		is_inside_dropable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body
		current_dropable = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable') and body == current_dropable:
		is_inside_dropable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 1)
		current_dropable = null

		# Réinitialisez la liste des objets dans la même zone
		objects_in_same_dropable.clear()
