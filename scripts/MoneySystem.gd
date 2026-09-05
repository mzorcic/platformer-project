class_name MoneySystem
extends Node

signal money_changed(money: int)

@onready var money_label: Label = $"../../HUD/Control/Stats/MoneyLabel"
var money: int


func _ready() -> void:
	money_label.text = "$%d" % money


func add_money(amount: int):
	money += amount
	money_changed.emit(money)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_key"):
		add_money(20)
