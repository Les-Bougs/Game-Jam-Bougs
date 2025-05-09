extends Node2D

@onready var star_platform = $ZoneFinal
@onready var validate_stars_button = $Validate
@onready var star_counter_label = $StarCounterUI

var current_score: int = 0

# Positions initiales des objets spawnables
var spawnable_positions = {
	"Rectangle": Vector2(232, 768),
	"Circle": Vector2(552, 768),
	"Triangle": Vector2(872, 768),
	"Star": Vector2(1192, 768)
}

func _ready():
	validate_stars_button.pressed.connect(_on_validate_stars_button_pressed)
	star_counter_label.text = "Stars: 0"

func _on_validate_stars_button_pressed():
	if star_platform.has_method("validate_stars"):
		var new_stars = star_platform.validate_stars()
		current_score += new_stars
		star_counter_label.text = "Stars: " + str(current_score) 
