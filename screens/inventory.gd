class_name Inventory
extends Control

signal inventory_changed(items)

const SLOT_COUNT := 18

var items: Array = []


func _ready() -> void:
	items.resize(SLOT_COUNT)


func add_item(item_texture: Texture2D) -> bool:
	for i in range(SLOT_COUNT):
		if items[i] == null:
			items[i] = item_texture
			inventory_changed.emit(items)
			return true
	print("Inventory is full")
	return false
