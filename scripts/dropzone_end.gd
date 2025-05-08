extends "res://scripts/dropzone.gd"

signal star_count_changed(count: int)

func _ready():
	super._ready()
	accepted_types = "Star"
	update_star_counter()

func update_label():
	super.update_label()
	update_star_counter()

func update_star_counter():
	var star_count = 0
	for obj in contained_objects:
		if is_instance_valid(obj) and obj.object_type == "Star":
			star_count += 1
	emit_signal("star_count_changed", star_count) 
