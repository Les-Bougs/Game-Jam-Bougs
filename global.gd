extends Node2D

var is_dragging = false
var day_nb = 0

var level_state = "afternoon"

var player_money: int = 0
var player_happiness: int = 50
var union_pressure: int = 50
var boss_satisfaction: int = 50
var work_pressure: int = 50

var tuto = false
var first_pick = true
var first_drop = true
var first_send = true
var first_day = true

var game_over = false
var rent_value = 15
