class_name ChestInventory
extends Node

signal inventory_changed(items)

const SLOT_COUNT := 6

var items: Array[InventoryStack] = []


func _ready() -> void:
	items.resize(SLOT_COUNT)


func add_item(item: ItemData, amount: int = 1) -> bool:
	if item == null:
		return false

	if amount <= 0:
		return false

	# Try to add to an existing stack first
	if item.is_stackable:
		for stack in items:
			if stack == null:
				continue

			if stack.item == item:
				if stack.amount < item.max_stack:
					var space: int = item.max_stack - stack.amount
					var amount_to_add: int = min(amount, space)

					stack.amount += amount_to_add
					amount -= amount_to_add

					if amount <= 0:
						inventory_changed.emit(items)
						return true

	# Create new stacks
	while amount > 0:
		var empty_slot: int = find_empty_slot()

		if empty_slot == -1:
			print("Chest is full!")
			inventory_changed.emit(items)
			return false

		var amount_for_stack: int = amount

		if item.is_stackable:
			amount_for_stack = min(amount, item.max_stack)

		items[empty_slot] = InventoryStack.new(
			item,
			amount_for_stack
		)

		amount -= amount_for_stack

	inventory_changed.emit(items)
	return true


func find_empty_slot() -> int:
	for i in range(SLOT_COUNT):
		if items[i] == null:
			return i

	return -1


func get_stack(slot_index: int) -> InventoryStack:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return null

	return items[slot_index]


func remove_item(slot_index: int, amount: int = 1) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false

	var stack: InventoryStack = items[slot_index]

	if stack == null:
		return false

	stack.amount -= amount

	if stack.amount <= 0:
		items[slot_index] = null

	inventory_changed.emit(items)
	return true


func set_item(slot_index: int, item: ItemData) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false

	if item == null:
		items[slot_index] = null
	else:
		items[slot_index] = InventoryStack.new(item, 1)

	inventory_changed.emit(items)

	return true


func move_item(from_slot: int, to_slot: int) -> void:
	if from_slot < 0 or from_slot >= SLOT_COUNT:
		return

	if to_slot < 0 or to_slot >= SLOT_COUNT:
		return

	var temp: InventoryStack = items[from_slot]

	items[from_slot] = items[to_slot]
	items[to_slot] = temp

	inventory_changed.emit(items)
