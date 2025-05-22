extends Node

const OBJECT_SCENE = preload("res://scenes/object.tscn")

enum ObjectType {
	RECTANGLE,
	CIRCLE,
	TRIANGLE,
	STAR,
	HEXAGON
}

var frame_ids = {}
const SPAWNABLE_TYPES = ["CircuitBoard", "SolderingIron", "Transistor", "TransistorModule"]

func _ready():
	load_frame_ids()

func load_frame_ids():
	var file = FileAccess.open("res://scripts/object_utils/frame_ids.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		frame_ids = JSON.parse_string(content)

func create_object(type: String, position: Vector2, scale: Vector2, parent: Node, spawnable: bool = false) -> Node2D:
	var object = OBJECT_SCENE.instantiate()
	object.object_type = type
	object.position = position
	object.scale = scale
	object.spawnable = spawnable and SPAWNABLE_TYPES.has(type)
	
	if frame_ids.has(type):
		object.get_node("AnimatedSprite2D").frame = frame_ids[type]
	
	parent.add_child(object)
	return object

func spawn_in_pile(type: String, pile_position: Vector2, scale: Vector2, parent: Node) -> Node2D:
	return create_object(type, pile_position, scale, parent, true)

func create_combination_result(type: String, position: Vector2, scale: Vector2, parent: Node) -> Node2D:
	# Les résultats de fusion ne sont jamais spawnables
	return create_object(type, position, scale, parent, false)
