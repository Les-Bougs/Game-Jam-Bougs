extends Node

# Référence au CombinationManager pour vérifier les combinaisons valides
var combination_manager: Node

# Référence à l'ObjectFactory pour créer les objets résultants
var object_factory: Node

func _ready():
	combination_manager = get_node("/root/CombinationManager")
	object_factory = get_node("/root/ObjectFactory")

# Vérifie et effectue la combinaison si possible
func try_combine(object1: Node2D, object2: Node2D, drop_zone: Node2D) -> bool:
	if not can_combine(object1, object2):
		return false
		
	var result_type = combination_manager.get_combination_result(object1.object_type, object2.object_type)
	if result_type.is_empty():
		return false
		
	# Crée l'objet résultant
	var result = object_factory.create_combination_result(
		result_type,
		drop_zone.position,
		object1.scale,  # On utilise l'échelle du premier objet comme référence
		drop_zone.get_parent()
	)
	
	# Nettoie les objets combinés
	cleanup_combined_objects(object1, object2, drop_zone)
	
	return true

# Vérifie si deux objets peuvent être combinés
func can_combine(object1: Node2D, object2: Node2D) -> bool:
	if not is_valid_for_combination(object1) or not is_valid_for_combination(object2):
		return false
		
	if object1.current_dropable != object2.current_dropable:
		return false
		
	return combination_manager.can_combine(object1.object_type, object2.object_type)

# Vérifie si un objet est valide pour la combinaison
func is_valid_for_combination(object: Node2D) -> bool:
	return (
		is_instance_valid(object) and 
		object.has_method("queue_free") and 
		object.has_method("_exit_tree") and
		object.current_dropable != null
	)

# Nettoie les objets après une combinaison réussie
func cleanup_combined_objects(object1: Node2D, object2: Node2D, drop_zone: Node2D) -> void:
	if is_instance_valid(object1):
		drop_zone.remove_object(object1)
		object1.queue_free()
		
	if is_instance_valid(object2):
		drop_zone.remove_object(object2)
		object2.queue_free()
