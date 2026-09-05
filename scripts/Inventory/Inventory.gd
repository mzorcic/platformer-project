class_name Inventory
extends Node

signal inventory_changed(items)

const SLOT_COUNT := 6

var items: Array = [null, null, null, null, null, null]


func add_item(item):
	for i in range(SLOT_COUNT):
		if items[i] == null:
			items[i] = item
			inventory_changed.emit(items)
			return true
	
	print("Inventory full!")
	return false


func remove_item(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < SLOT_COUNT:
		items[slot_index] = null
		inventory_changed.emit(items)
