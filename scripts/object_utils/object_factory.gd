extends Node

const OBJECT_SCENE = preload("res://scenes/object.tscn")

enum ObjectType {
	RECTANGLE,
	CIRCLE,
	TRIANGLE,
	STAR,
	HEXAGON
}

const TYPE_TO_FRAME = {
	"Rectangle": 0,
	"Circle": 1,
	"Triangle": 2,
	"Star": 3,
	"Hexagon": 4
}

const SPAWNABLE_TYPES = ["Rectangle", "Circle", "Triangle"]

func create_object(type: String, position: Vector2, scale: Vector2, parent: Node, spawnable: bool = false) -> Node2D:
	var object = OBJECT_SCENE.instantiate()
	object.object_type = type
	object.position = position
	object.scale = scale
	object.spawnable = spawnable and SPAWNABLE_TYPES.has(type)
	
	if TYPE_TO_FRAME.has(type):
		object.get_node("AnimatedSprite2D").frame = TYPE_TO_FRAME[type]
	
	parent.add_child(object)
	return object

func spawn_in_pile(type: String, pile_position: Vector2, scale: Vector2, parent: Node) -> Node2D:
	return create_object(type, pile_position, scale, parent, true)

func create_combination_result(type: String, position: Vector2, scale: Vector2, parent: Node) -> Node2D:
	return create_object(type, position, scale, parent, SPAWNABLE_TYPES.has(type))
