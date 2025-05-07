extends StaticBody2D

var contained_objects = []
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	add_to_group("dropable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = global.is_dragging
	clean_invalid_objects()

func add_object(obj):
	print('adding')
	if obj not in contained_objects:
		contained_objects.append(obj)
		print("Objets dans la case: ", contained_objects)
	label.text = str(get_list_shape(contained_objects))

func remove_object(obj):
	print('removing')
	if obj in contained_objects:
		contained_objects.erase(obj)
		print("Objets dans la case: ", contained_objects)
		label.text = str(get_list_shape(contained_objects))

func get_contained_objects():
	return contained_objects

func get_list_shape(objects):
	var list_shape = []
	for obj in objects:
		if is_instance_valid(obj):
			list_shape.append(obj.shape_type)
	return list_shape

func clean_invalid_objects():
	var valid_objects = []
	for obj in contained_objects:
		if is_instance_valid(obj):
			valid_objects.append(obj)
	contained_objects = valid_objects
	label.text = str(get_list_shape(contained_objects))
