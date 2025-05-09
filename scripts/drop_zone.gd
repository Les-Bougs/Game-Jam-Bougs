extends StaticBody2D

signal star_count_changed(count: int)

@export_enum("Normal", "StarCollector") var zone_type: String = "Normal"
@export var accepted_types: Array[String] = []

var contained_objects = []
@onready var label = $Label

func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	add_to_group("dropable")
	if zone_type == "StarCollector":
		accepted_types = ["Star"]
		update_star_counter()

func _process(delta: float) -> void:
	update_label()

func add_object(obj):
	if obj not in contained_objects:
		contained_objects.append(obj)
		update_label()
		if zone_type == "StarCollector":
			update_star_counter()

func remove_object(obj):
	if obj in contained_objects:
		contained_objects.erase(obj)
		update_label()
		if zone_type == "StarCollector":
			update_star_counter()

func get_contained_objects():
	return contained_objects

func update_label():
	var shapes = []
	for obj in contained_objects:
		if is_instance_valid(obj):
			shapes.append(obj.object_type)
	label.text = str(shapes)

func update_star_counter():
	if zone_type != "StarCollector":
		return
		
	var star_count = 0
	for obj in contained_objects:
		if is_instance_valid(obj) and obj.object_type == "Star":
			star_count += 1
	emit_signal("star_count_changed", star_count)

func is_valid_placement(obj) -> bool:
	# Si c'est une zone de collecte d'étoiles, vérifier le type
	if zone_type == "StarCollector" and obj.object_type != "Star":
		return false
		
	# Si des types spécifiques sont acceptés, vérifier
	if accepted_types.size() > 0 and not obj.object_type in accepted_types:
		return false
	
	# Si la zone est vide, le placement est valide
	if contained_objects.size() == 0:
		return true
	
	# Vérifier les conditions pour les objets déjà présents
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
