extends CanvasLayer


@onready var union_gauge: AnimatedSprite2D = $Union/UnionGauge
@onready var happy_gauge: AnimatedSprite2D = $Happy/HappyGauge
@onready var money_label: Label = $Money/MoneyLabel

var union_level = 0
var happy_level = 0
var money = 0


func _process(delta: float) -> void:
	union_gauge.frame = int(union_level / 10)
	happy_gauge.frame = int(happy_level / 10)
	money_label.text = "Money " + str(money)
