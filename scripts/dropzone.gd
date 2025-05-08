extends StaticBody2D

var contained_objects = []
@onready var label = $Label
@export_enum("All", "Star") var accepted_types: String = "All"


func _ready():
	match accepted_types:
		"All":
			$AnimatedSprite2D.frame = 0
		"Star":
			$AnimatedSprite2D.frame = 1
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	add_to_group("dropable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_label()
	#visible = global.is_dragging

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
	label.text = str(shapes)

func is_valid_placement(obj) -> bool:
	# Vérifier si le type d'objet est accepté dans cette case
	if accepted_types == "Star" and obj.object_type != "Star":
		return false
		
	# Si la zone est vide, le placement est valide si le type est accepté
	if contained_objects.size() == 0:
		return true
	
	# Si la zone contient des objets, on vérifie les conditions
	for contained_obj in contained_objects:
		if not is_instance_valid(contained_obj):
			continue
			
		# Si on trouve un objet du même type, le placement est valide
		if contained_obj.object_type == obj.object_type:
			return true
		
		# Si on trouve un objet qui peut fusionner avec celui-ci, le placement est valide
		var combination_manager = get_node("/root/CombinationManager")
		if combination_manager.can_combine(contained_obj.object_type, obj.object_type):
			return true
	
	return false
