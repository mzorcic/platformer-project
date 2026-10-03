class_name EquipmentSlot
extends Panel

@onready var item_icon: TextureRect = $ItemIcon

@export var equipment_index: int = 0

var equipment: Equipment = null
var inventory: Inventory = null
var chest: ChestInventory = null
var chest_slot: ChestSlot
var item_data: ItemData = null


func set_item(item: ItemData) -> void:

	item_data = item

	if item == null:
		item_icon.texture = null
		return

	item_icon.texture = item.icon
	update_tooltip_if_hovered()


func clear_slot() -> void:

	item_data = null
	item_icon.texture = null


func _get_current_item() -> ItemData:

	if equipment == null:
		return null

	match equipment_index:

		-1:
			return equipment.helmet

		0:
			return equipment.weapon

		1:
			return equipment.shield

		2:
			return equipment.boots

		3, 4, 5, 6, 7:
			var trinket_index := equipment_index - 3

			if trinket_index >= 0 and trinket_index < equipment.trinkets.size():
				return equipment.trinkets[trinket_index]

	return null


func _get_equipment_type() -> ItemData.EquipmentType:

	match equipment_index:

		-1:
			return ItemData.EquipmentType.HELMET

		0:
			return ItemData.EquipmentType.WEAPON

		1:
			return ItemData.EquipmentType.SHIELD

		2:
			return ItemData.EquipmentType.BOOTS

		3, 4, 5, 6, 7:
			return ItemData.EquipmentType.TRINKET

	return ItemData.EquipmentType.ITEM


func _can_drop_data(_at_position: Vector2, data) -> bool:

	if not data is Dictionary:
		return false

	if not data.has("source"):
		return false

	if not data.has("item"):
		return false

	var item: ItemData = data["item"]

	if item == null:
		return false

	var target_type := _get_equipment_type()

	# Inventory → Equipment
	if data["source"] == "inventory":
		return item.equipment_type == target_type
	
	if data["source"] == "chest":
		return item.equipment_type == target_type

	# Equipment → Equipment
	if data["source"] == "equipment":

		if not data.has("equipment_type"):
			return false

		return item.equipment_type == target_type

	return false


func _drop_data(_at_position: Vector2, data) -> void:

	if equipment == null:
		return

	if inventory == null:
		return

	if not data is Dictionary:
		return

	if not data.has("item"):
		return

	var item: ItemData = data["item"]

	if item == null:
		return

	if data["source"] == "inventory":

		if not data.has("slot_index"):
			return

		var from_slot: int = data["slot_index"]

		var old_equipment_item: ItemData = null


		match equipment_index:

			-1:
				old_equipment_item = equipment.swap_helmet(item)

			0:
				old_equipment_item = equipment.swap_weapon(item)

			1:
				old_equipment_item = equipment.swap_shield(item)

			2:
				old_equipment_item = equipment.swap_boots(item)

			3, 4, 5, 6, 7:

				var trinket_index: int = equipment_index - 3

				old_equipment_item = equipment.swap_trinket(
					trinket_index,
					item
				)

			_:
				return


		# Put the old equipment item into the inventory.
		# If the equipment slot was empty, this puts null there.
		inventory.set_item(from_slot, old_equipment_item)

		return
	
	if data["source"] == "chest":

		if not data.has("slot_index"):
			return

		var from_slot: int = data["slot_index"]

		var old_equipment_item: ItemData = null


		match equipment_index:

			-1:
				old_equipment_item = equipment.swap_helmet(item)

			0:
				old_equipment_item = equipment.swap_weapon(item)

			1:
				old_equipment_item = equipment.swap_shield(item)

			2:
				old_equipment_item = equipment.swap_boots(item)

			3, 4, 5, 6, 7:

				var trinket_index: int = equipment_index - 3

				old_equipment_item = equipment.swap_trinket(
					trinket_index,
					item
				)

			_:
				return


		# Put the old equipment item into the inventory.
		# If the equipment slot was empty, this puts null there.
		chest.set_item(from_slot, old_equipment_item)

		return
	
	# =====================================================
	# EQUIPMENT → EQUIPMENT
	# =====================================================

	if data["source"] == "equipment":

		if not data.has("equipment_slot"):
			return

		var source_slot: EquipmentSlot = data["equipment_slot"]

		if source_slot == self:
			return


		# Only allow the same equipment type.
		if item.equipment_type != _get_equipment_type():
			return


		var target_item: ItemData = _get_current_item()


		# =================================================
		# TRINKET → TRINKET
		# =================================================

		if equipment_index >= 3 and equipment_index <= 7:

			if not data.has("equipment_index"):
				return

			var source_index: int = data["equipment_index"]

			if source_index < 3 or source_index > 7:
				return

			var target_trinket_index: int = equipment_index - 3
			var source_trinket_index: int = source_index - 3

			equipment.trinkets[target_trinket_index] = item
			equipment.trinkets[source_trinket_index] = target_item


		# =================================================
		# WEAPON
		# =================================================

		elif equipment_index == 0:

			equipment.weapon = item


		# =================================================
		# HELMET
		# =================================================

		elif equipment_index == -1:

			equipment.helmet = item


		# =================================================
		# SHIELD
		# =================================================

		elif equipment_index == 1:

			equipment.shield = item


		# =================================================
		# BOOTS
		# =================================================

		elif equipment_index == 2:

			equipment.boots = item

		else:
			return


		source_slot.set_item(target_item)
		set_item(item)

		equipment.equipment_changed.emit()


func _get_drag_data(_at_position: Vector2):

	var current_item: ItemData = _get_current_item()

	if current_item == null:
		return null

	var preview := TextureRect.new()

	preview.texture = current_item.icon
	preview.custom_minimum_size = Vector2(50, 50)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_drag_preview(preview)


	var drag_data := {
	"source": "equipment",
	"equipment_index": equipment_index,
	"equipment_type": _get_equipment_type(),
	"item": current_item,
	"equipment_slot": self
	}

	if equipment_index >= 3 and equipment_index <= 7:
		drag_data["trinket_index"] = equipment_index - 3

	return drag_data


func _drop_chest_item(data) -> void:
	if inventory == null:
		return

	if not data.has("chest"):
		return

	if not data.has("slot_index"):
		return

	var chest: ChestInventory = data["chest"]
	var from_slot: int = data["slot_index"]

	if chest == null:
		return

	if from_slot < 0 or from_slot >= chest.SLOT_COUNT:
		return

	# Get the item from the chest
	var source_stack: InventoryStack = chest.get_stack(from_slot)

	if source_stack == null:
		return

	if source_stack.item == null:
		return

	# How many are we moving?
	var amount_to_move: int = data.get(
		"amount",
		source_stack.amount
	)

	amount_to_move = min(
		amount_to_move,
		source_stack.amount
	)

	if amount_to_move <= 0:
		return

	# What is currently in the inventory slot?
	var target_stack: InventoryStack = equipment.get_stack(equipment_index)


	# ------------------------------------------------
	# INVENTORY SLOT IS EMPTY
	# ------------------------------------------------

	if target_stack == null:

		equipment.items[equipment_index] = InventoryStack.new(
			source_stack.item,
			amount_to_move
		)

		source_stack.amount -= amount_to_move

		if source_stack.amount <= 0:
			chest.items[from_slot] = null

		chest.inventory_changed.emit(chest.items)
		equipment.inventory_changed.emit(equipment.items)

		return


	# ------------------------------------------------
	# SAME STACKABLE ITEM
	# ------------------------------------------------

	if (
		target_stack.item == source_stack.item
		and source_stack.item.is_stackable
	):
		var max_stack: int = source_stack.item.max_stack

		var free_space: int = (
			max_stack - target_stack.amount
		)

		if free_space <= 0:
			return

		var actual_amount: int = min(
			amount_to_move,
			free_space
		)

		target_stack.amount += actual_amount
		source_stack.amount -= actual_amount

		if source_stack.amount <= 0:
			chest.items[from_slot] = null

		chest.inventory_changed.emit(chest.items)
		equipment.inventory_changed.emit(equipment.items)

		return


	# ------------------------------------------------
	# DIFFERENT ITEM
	# ------------------------------------------------

	# Only allow a full stack to swap.
	if amount_to_move != source_stack.amount:
		return

	# Swap chest item with inventory item.
	var temp: InventoryStack = equipment.items[equipment_index]

	equipment.items[equipment_index] = source_stack
	chest.items[from_slot] = temp

	chest.inventory_changed.emit(chest.items)
	equipment.inventory_changed.emit(equipment.items)


func _on_mouse_entered() -> void:
	if item_data == null:
		return

	if inventory != null:
		var hud = inventory.get_parent().get_node_or_null("../HUD")

		if hud:
			hud.show_item_tooltip(item_data)


func _on_mouse_exited() -> void:
	if inventory != null:
		var hud = inventory.get_parent().get_node_or_null("../HUD")

		if hud:
			hud.hide_item_tooltip()


func update_tooltip_if_hovered() -> void:
	if not is_visible_in_tree():
		return

	if get_global_rect().has_point(get_global_mouse_position()):
		if item_data != null:
			if equipment != null:
				var hud = equipment.get_parent().get_node_or_null("../HUD")

				if hud:
					hud.show_item_tooltip(item_data)
		else:
			if equipment != null:
				var hud = equipment.get_parent().get_node_or_null("../HUD")

				if hud:
					hud.hide_item_tooltip()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	if event.button_index != MOUSE_BUTTON_RIGHT:
		return

	var current_item: ItemData = _get_current_item()

	if current_item == null:
		return

	unequip_item()

	_on_mouse_exited()
	accept_event()


func unequip_item() -> void:
	if equipment == null:
		return

	if inventory == null:
		return

	var current_item: ItemData = _get_current_item()

	if current_item == null:
		return

	var empty_slot: int = inventory.find_empty_slot()

	if empty_slot == -1:
		return

	var removed_item: ItemData = null

	match equipment_index:
		-1:
			removed_item = equipment.unequip_helmet()

		0:
			removed_item = equipment.unequip_weapon()

		1:
			removed_item = equipment.unequip_shield()

		2:
			removed_item = equipment.unequip_boots()

		3, 4, 5, 6, 7:
			var trinket_index: int = equipment_index - 3
			removed_item = equipment.unequip_trinket(trinket_index)

		_:
			return

	if removed_item == null:
		return

	inventory.set_item(empty_slot, removed_item)
