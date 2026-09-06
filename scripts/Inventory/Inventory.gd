class_name Inventory
extends Node

signal inventory_changed(items)

const SLOT_COUNT := 15

var items: Array[ItemData] = []


func _ready() -> void:
	items.resize(SLOT_COUNT)


func add_item(item: ItemData) -> bool:
	if item == null:
		return false

	for i in range(SLOT_COUNT):
		if items[i] == null:
			items[i] = item

			inventory_changed.emit(items)

			return true

	return false


func remove_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return

	items[slot_index] = null

	inventory_changed.emit(items)


func set_item(slot_index: int, item: ItemData) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false

	items[slot_index] = item

	inventory_changed.emit(items)

	return true


func move_item(from_slot: int, to_slot: int) -> void:
	if from_slot < 0 or from_slot >= SLOT_COUNT:
		return

	if to_slot < 0 or to_slot >= SLOT_COUNT:
		return

	var temp: ItemData = items[from_slot]

	items[from_slot] = items[to_slot]
	items[to_slot] = temp

	inventory_changed.emit(items)


func get_item(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return null

	return items[slot_index]


func is_full() -> bool:
	for item in items:
		if item == null:
			return false

	return true
