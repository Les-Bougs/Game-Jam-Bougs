extends CanvasLayer

@onready var union_gauge: AnimatedSprite2D = $Union/UnionGauge
@onready var happy_gauge: AnimatedSprite2D = $Happy/HappyGauge
@onready var money_label: Label = $Money/MoneyLabel
@onready var debug_add_money: Button = $DebugButtons/DebugAddMoney
@onready var debug_remove_money: Button = $DebugButtons/DebugRemoveMoney

func _ready() -> void:
	debug_add_money.pressed.connect(_on_debug_add_money_pressed)
	debug_remove_money.pressed.connect(_on_debug_remove_money_pressed)

func _process(_delta: float) -> void:
	var union_level = 0
	var happy_level = 0
	var money = Globals.player_money
	
	union_gauge.frame = int(union_level / 10)
	happy_gauge.frame = int(happy_level / 10)
	money_label.text = "Money " + str(money)

func _on_debug_add_money_pressed() -> void:
	Globals.player_money += 10

func _on_debug_remove_money_pressed() -> void:
	Globals.player_money -= 10
