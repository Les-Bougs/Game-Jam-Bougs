extends StaticBody2D

var contained_objects = []
@onready var label = $Label

func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	add_to_group("dropable")

func _process(delta: float) -> void:
	visible = global.is_dragging
	update_label()

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
			shapes.append(obj.shape_type)
	label.text = str(shapes)

func is_valid_placement(obj) -> bool:
	# Si la zone est vide, le placement est toujours valide
	if contained_objects.size() == 0:
		return true
	
	# Si la zone contient des objets, on vérifie les conditions
	for contained_obj in contained_objects:
		if not is_instance_valid(contained_obj):
			continue
			
		# Si on trouve un objet du même type, le placement est valide
		if contained_obj.shape_type == obj.shape_type:
			return true
		# Si on trouve un objet qui peut fusionner avec celui-ci, le placement est valide
		var combination_manager = get_node("/root/CombinationManager")
		if combination_manager.can_combine(contained_obj.shape_type, obj.shape_type):
			return true
	
	return false 
