class_name MoneySystem
extends Node

signal money_changed(money: int)

var money: int


func _ready() -> void:
	await get_tree().process_frame
	money_changed.emit(money)


func add_money(amount: int):
	money += amount
	money_changed.emit(money)
