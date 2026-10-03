class_name InventoryStack
extends RefCounted

var item: ItemData
var amount: int


func _init(item_data: ItemData, stack_amount: int = 1) -> void:
	item = item_data
	amount = stack_amount
