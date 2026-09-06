extends Control

@onready var inventory_grid: GridContainer = $GridContainer


func update_inventory(items: Array) -> void:
	var slots = inventory_grid.get_children()

	for i in range(slots.size()):
		if i < items.size() and items[i] != null:
			slots[i].set_item(items[i])
		else:
			slots[i].clear_slot()
