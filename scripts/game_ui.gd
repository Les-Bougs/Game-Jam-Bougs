extends CanvasLayer

@onready var union_gauge: AnimatedSprite2D = $Union/UnionGauge
@onready var happy_gauge: AnimatedSprite2D = $Happy/HappyGauge
@onready var money_label: Label = $Money/MoneyLabel
@onready var debug_add_money: Button = $DebugButtons/DebugAddMoney
@onready var debug_remove_money: Button = $DebugButtons/DebugRemoveMoney
@onready var union_change_label: Label = $Union/UnionChangeLabel
@onready var happy_change_label: Label = $Happy/HappyChangeLabel
@onready var money_change_label: Label = $Money/MoneyChangeLabel

var last_union_value: int = 50
var last_happy_value: int = 50
var change_timer: float = 1.5
var union_timer: float = 0.0
var happy_timer: float = 0.0

var current_union_frame: float = 5.0
var current_happy_frame: float = 5.0
var animation_speed: float = 10.0 # frames/seconde

var last_money_value: int = 0
var money_timer: float = 0.0
var displayed_money: float = 0.0
var money_anim_speed: float = 200.0 # vitesse d'animation (unités/seconde)

func _ready() -> void:
	debug_add_money.pressed.connect(_on_debug_add_money_pressed)
	debug_remove_money.pressed.connect(_on_debug_remove_money_pressed)
	last_union_value = Globals.union_pressure
	last_happy_value = Globals.player_happiness
	current_union_frame = int(clamp(Globals.union_pressure, 0, 100) / 10)
	current_happy_frame = int(clamp(Globals.player_happiness, 0, 100) / 10)
	last_money_value = Globals.player_money
	displayed_money = float(Globals.player_money)

func _process(delta: float) -> void:
	var union_level = clamp(Globals.union_pressure, 0, 100)
	var happy_level = clamp(Globals.player_happiness, 0, 100)
	var money = Globals.player_money
	
	# Animation changement union
	if union_level != last_union_value:
		var diff = union_level - last_union_value
		union_change_label.text = ("+" if diff > 0 else "") + str(diff)
		union_change_label.visible = true
		union_timer = change_timer
		last_union_value = union_level
	if union_timer > 0.0:
		union_timer -= delta
		if union_timer <= 0.0:
			union_change_label.visible = false

	# Animation changement happiness
	if happy_level != last_happy_value:
		var diff = happy_level - last_happy_value
		happy_change_label.text = ("+" if diff > 0 else "") + str(diff)
		happy_change_label.visible = true
		happy_timer = change_timer
		last_happy_value = happy_level
	if happy_timer > 0.0:
		happy_timer -= delta
		if happy_timer <= 0.0:
			happy_change_label.visible = false

	# Animation fluide des barres
	var target_union_frame = int(union_level / 10)
	if abs(current_union_frame - target_union_frame) > 0.01:
		current_union_frame = move_toward(current_union_frame, target_union_frame, animation_speed * delta)
	union_gauge.frame = int(round(current_union_frame))

	var target_happy_frame = int(happy_level / 10)
	if abs(current_happy_frame - target_happy_frame) > 0.01:
		current_happy_frame = move_toward(current_happy_frame, target_happy_frame, animation_speed * delta)
	happy_gauge.frame = int(round(current_happy_frame))

	# Animation du label d'argent (compteur animé)
	if abs(displayed_money - money) > 0.01:
		displayed_money = move_toward(displayed_money, money, money_anim_speed * delta)
	money_label.text = "Money " + str(int(round(displayed_money)))

	# Animation changement argent
	if money != last_money_value:
		var diff = money - last_money_value
		money_change_label.text = ("+" if diff > 0 else "") + str(diff)
		money_change_label.visible = true
		money_timer = change_timer
		last_money_value = money
	if money_timer > 0.0:
		money_timer -= delta
		if money_timer <= 0.0:
			money_change_label.visible = false

func _on_debug_add_money_pressed() -> void:
	Globals.player_money += 10

func _on_debug_remove_money_pressed() -> void:
	Globals.player_money -= 10
