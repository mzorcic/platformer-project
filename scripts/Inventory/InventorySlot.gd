extends Panel

@onready var item_icon: TextureRect = $ItemIcon
@onready var amount_label: Label = $StackAmount

var current_item: ItemData = null
var current_amount: int = 0

var slot_index: int = -1
var inventory: Inventory = null
var equipment: Equipment = null


func set_item(item: ItemData, amount: int = 1) -> void:
	current_item = item
	current_amount = amount

	if item == null:
		clear_slot()
		return

	item_icon.texture = item.icon

	if amount > 1:
		amount_label.text = str(amount)
		amount_label.visible = true
	else:
		amount_label.text = ""
		amount_label.visible = false


func clear_slot() -> void:
	current_item = null
	current_amount = 0
	item_icon.texture = null
	amount_label.text = ""
	amount_label.visible = false


func _get_drag_data(_at_position: Vector2):
	if inventory == null:
		return null

	var stack: InventoryStack = inventory.get_stack(slot_index)

	if stack == null:
		return null

	if stack.item == null:
		return null

	var drag_amount: int = stack.amount

	if Input.is_key_pressed(KEY_CTRL):
		drag_amount = stack.amount / 2
		drag_amount = max(1, drag_amount)

	var preview := TextureRect.new()
	preview.texture = stack.item.icon
	preview.custom_minimum_size = Vector2(50, 50)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_drag_preview(preview)

	return {
		"source": "inventory",
		"slot_index": slot_index,
		"item": stack.item,
		"amount": drag_amount
	}


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

	if data["source"] == "inventory":
		if not data.has("slot_index"):
			return false

		var from_slot: int = data["slot_index"]

		if from_slot == slot_index:
			return false

		return true
	
	if data["source"] == "equipment":
		if not data.has("equipment_type"):
			return false
		return true
	
	if data["source"] == "chest":
		return true
	
	return false


func _drop_data(_at_position: Vector2, data) -> void:
	if inventory == null:
		return

	if not data is Dictionary:
		return

	if not data.has("source"):
		return

	if data["source"] == "inventory":
		_drop_inventory_item(data)
		return

	if data["source"] == "equipment":
		_drop_equipment_item(data)
		return
	
	if data["source"] == "chest":
		_drop_chest_item(data)
		return


func _drop_inventory_item(data) -> void:
	if not data.has("slot_index"):
		return

	var from_slot: int = data["slot_index"]

	if from_slot == slot_index:
		return

	var source_stack: InventoryStack = inventory.get_stack(from_slot)

	if source_stack == null:
		return

	if source_stack.item == null:
		return

	var target_stack: InventoryStack = inventory.get_stack(slot_index)

	var amount_to_move: int = data.get("amount", source_stack.amount)

	amount_to_move = min(
		amount_to_move,
		source_stack.amount
	)

	if amount_to_move <= 0:
		return

	if target_stack == null:
		if amount_to_move == source_stack.amount:
			inventory.move_item(
				from_slot,
				slot_index
			)
			return

		var moved_item: ItemData = source_stack.item

		inventory.items[slot_index] = InventoryStack.new(
			moved_item,
			amount_to_move
		)

		source_stack.amount -= amount_to_move

		inventory.inventory_changed.emit(
			inventory.items
		)

		return

	if (
		target_stack.item == source_stack.item
		and source_stack.item.is_stackable
	):
		var max_stack: int = source_stack.item.max_stack

		var free_space: int = max_stack - target_stack.amount

		if free_space <= 0:
			if amount_to_move == source_stack.amount:
				inventory.move_item(
					from_slot,
					slot_index
				)

			return

		var actual_amount: int = min(
			amount_to_move,
			free_space
		)

		target_stack.amount += actual_amount
		source_stack.amount -= actual_amount

		if source_stack.amount <= 0:
			inventory.items[from_slot] = null

		inventory.inventory_changed.emit(
			inventory.items
		)

		return

	if amount_to_move != source_stack.amount:
		return

	inventory.move_item(
		from_slot,
		slot_index
	)


func _drop_equipment_item(data) -> void:
	if equipment == null:
		return

	if not data.has("equipment_type"):
		return

	if not data.has("item"):
		return

	var equipment_type: ItemData.EquipmentType = data["equipment_type"]
	var equipment_item: ItemData = data["item"]

	if equipment_item == null:
		return

	var inventory_stack: InventoryStack = inventory.get_stack(slot_index)

	if inventory_stack == null:
		var removed_item: ItemData = unequip_from_data(data)

		if removed_item == null:
			return

		inventory.set_item(
			slot_index,
			removed_item
		)

		return

	var inventory_item: ItemData = inventory_stack.item

	if inventory_item == null:
		return

	if inventory_item.equipment_type != equipment_type:
		return

	var old_equipment_item: ItemData = swap_equipment_from_data(
		data,
		inventory_item
	)

	if old_equipment_item == null:
		return

	inventory.set_item(
		slot_index,
		old_equipment_item
	)


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
	var target_stack: InventoryStack = inventory.get_stack(slot_index)


	# ------------------------------------------------
	# INVENTORY SLOT IS EMPTY
	# ------------------------------------------------

	if target_stack == null:

		inventory.items[slot_index] = InventoryStack.new(
			source_stack.item,
			amount_to_move
		)

		source_stack.amount -= amount_to_move

		if source_stack.amount <= 0:
			chest.items[from_slot] = null

		chest.inventory_changed.emit(chest.items)
		inventory.inventory_changed.emit(inventory.items)

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
		inventory.inventory_changed.emit(inventory.items)

		return


	# ------------------------------------------------
	# DIFFERENT ITEM
	# ------------------------------------------------

	# Only allow a full stack to swap.
	if amount_to_move != source_stack.amount:
		return

	# Swap chest item with inventory item.
	var temp: InventoryStack = inventory.items[slot_index]

	inventory.items[slot_index] = source_stack
	chest.items[from_slot] = temp

	chest.inventory_changed.emit(chest.items)
	inventory.inventory_changed.emit(inventory.items)


func unequip_from_data(data) -> ItemData:
	if not data.has("equipment_type"):
		return null

	var equipment_type: ItemData.EquipmentType = data["equipment_type"]

	match equipment_type:
		ItemData.EquipmentType.HELMET:
			return equipment.unequip_helmet()

		ItemData.EquipmentType.WEAPON:
			return equipment.unequip_weapon()

		ItemData.EquipmentType.SHIELD:
			return equipment.unequip_shield()

		ItemData.EquipmentType.BOOTS:
			return equipment.unequip_boots()

		ItemData.EquipmentType.TRINKET:
			if not data.has("trinket_index"):
				return null

			return equipment.unequip_trinket(
				data["trinket_index"]
			)

	return null


func swap_equipment_from_data(data, new_item: ItemData) -> ItemData:
	if not data.has("equipment_type"):
		return null

	var equipment_type: ItemData.EquipmentType = data["equipment_type"]

	match equipment_type:
		ItemData.EquipmentType.HELMET:
			return equipment.swap_helmet(new_item)

		ItemData.EquipmentType.WEAPON:
			return equipment.swap_weapon(new_item)

		ItemData.EquipmentType.SHIELD:
			return equipment.swap_shield(new_item)

		ItemData.EquipmentType.BOOTS:
			return equipment.swap_boots(new_item)

		ItemData.EquipmentType.TRINKET:
			if not data.has("trinket_index"):
				return null

			return equipment.swap_trinket(
				data["trinket_index"],
				new_item
			)

	return null


func _on_mouse_entered() -> void:
	if current_item == null:
		return

	if inventory == null:
		return

	var hud = inventory.get_parent().get_node_or_null("../HUD")

	if hud != null:
		hud.show_item_tooltip(current_item)


func _on_mouse_exited() -> void:
	if inventory == null:
		return

	var hud = inventory.get_parent().get_node_or_null("../HUD")

	if hud != null:
		hud.hide_item_tooltip()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if not event.is_pressed():
		return
	
	if event.button_index != MOUSE_BUTTON_RIGHT:
		return
	
	if current_item == null:
		return
	
	if current_item.equipment_type == current_item.EquipmentType.ITEM:
		use_item()
	
	elif current_item.equipment_type != current_item.EquipmentType.ITEM:
		equip_item()
		_on_mouse_exited()
	
	accept_event()


func use_item() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var health_system: HealthSystem = player.get_node_or_null("HealthSystem")
	var mana_system: ManaSystem = player.get_node_or_null("ManaSystem")
	
	if current_item == null:
		return
	
	if player == null:
		return
	
	if health_system == null:
		return
	
	if  current_item.healing > 0.0 and health_system.current_health < health_system.max_health and current_item.regen_mana > 0.0 and mana_system.current_mana < mana_system.max_mana:
		health_system.heal(current_item.healing)
		mana_system.regen_mana(current_item.regen_mana)
		inventory.remove_item(slot_index, 1)
		_on_mouse_exited()
	elif current_item.healing > 0.0 and health_system.current_health < health_system.max_health and current_item.regen_mana <= 0.0:
		health_system.heal(current_item.healing)
		inventory.remove_item(slot_index, 1)
		_on_mouse_exited()
	elif current_item.healing <= 0.0 and current_item.regen_mana > 0.0 and mana_system.current_mana < mana_system.max_mana:
		mana_system.regen_mana(current_item.regen_mana)
		inventory.remove_item(slot_index, 1)
		_on_mouse_exited()


func equip_item() -> void:
	if inventory == null:
		return

	if equipment == null:
		return

	if current_item == null:
		return

	var old_equipment: ItemData = null

	match current_item.equipment_type:
		ItemData.EquipmentType.HELMET:
			old_equipment = equipment.swap_helmet(current_item)

		ItemData.EquipmentType.WEAPON:
			old_equipment = equipment.swap_weapon(current_item)

		ItemData.EquipmentType.SHIELD:
			old_equipment = equipment.swap_shield(current_item)

		ItemData.EquipmentType.BOOTS:
			old_equipment = equipment.swap_boots(current_item)

		ItemData.EquipmentType.TRINKET:
			var empty_slot: int = -1

			for i in range(equipment.trinkets.size()):
				if equipment.trinkets[i] == null:
					empty_slot = i
					break

			if empty_slot != -1:
				equipment.equip_trinket(empty_slot, current_item)
				old_equipment = null
				inventory.remove_item(slot_index, 1)
			else:
				old_equipment = equipment.swap_trinket(0, current_item)

		
			return

	if old_equipment != null:
		inventory.set_item(slot_index, old_equipment)
	else:
		inventory.remove_item(slot_index, 1)
