class_name ChestSlot
extends Panel

@onready var item_icon: TextureRect = $ItemIcon
@onready var amount_label: Label = $StackAmount

var chest: ChestInventory = null
var inventory: Inventory = null
var equipment: Equipment = null

var slot_index: int = -1

var current_item: ItemData = null
var current_amount: int = 0


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


# =========================================================
# DRAG FROM CHEST
# =========================================================

func _get_drag_data(_at_position: Vector2):

	if chest == null:
		return null

	var stack: InventoryStack = chest.get_stack(slot_index)

	if stack == null:
		return null

	if stack.item == null:
		return null

	var drag_amount: int = stack.amount

	if Input.is_key_pressed(KEY_CTRL):
		drag_amount = max(1, stack.amount / 2)

	var preview := TextureRect.new()
	preview.texture = stack.item.icon
	preview.custom_minimum_size = Vector2(50, 50)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_drag_preview(preview)

	print(
		"Dragging from chest slot ",
		slot_index,
		": ",
		stack.item.item_name,
		" x",
		drag_amount
	)

	return {
		"source": "chest",
		"chest": chest,
		"slot_index": slot_index,
		"item": stack.item,
		"amount": drag_amount
	}


# =========================================================
# CAN DROP
# =========================================================

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
		return true
	
	if data["source"] == "equipment":
		return true

	if data["source"] == "chest":

		if not data.has("slot_index"):
			return false

		if data["slot_index"] == slot_index:
			return false

		return true

	return false


# =========================================================
# DROP
# =========================================================

func _drop_data(_at_position: Vector2, data) -> void:
	if chest == null:
		print("ERROR: ChestSlot has no chest!")
		return

	if not data is Dictionary:
		print("ERROR: Drag data isn't Dictionary")
		return

	if not data.has("source"):
		print("ERROR: Drag data has no source")
		return

	print("Drop source: ", data["source"])

	if data["source"] == "inventory":
		_drop_inventory_item(data)
		return
	
	if data["source"] == "equipment":
		_drop_equipment_item(data)
		return
	
	if data["source"] == "chest":
		_drop_chest_item(data)
		return


# =========================================================
# INVENTORY -> CHEST
# =========================================================

func _drop_inventory_item(data) -> void:
	
	if inventory == null:
		return

	if not data.has("slot_index"):
		return

	var from_slot: int = data["slot_index"]

	var source_stack: InventoryStack = inventory.get_stack(from_slot)

	if source_stack == null:
		return

	if source_stack.item == null:
		return

	var amount: int = data.get("amount", source_stack.amount)

	amount = min(amount, source_stack.amount)

	var target_stack: InventoryStack = chest.get_stack(slot_index)


	# ---------------------------------------------------------
	# EMPTY CHEST SLOT
	# ---------------------------------------------------------

	if target_stack == null:

		chest.items[slot_index] = InventoryStack.new(
			source_stack.item,
			amount
		)

		source_stack.amount -= amount

		if source_stack.amount <= 0:
			inventory.items[from_slot] = null

		inventory.inventory_changed.emit(inventory.items)
		chest.inventory_changed.emit(chest.items)

		return


	# ---------------------------------------------------------
	# SAME STACKABLE ITEM
	# ---------------------------------------------------------

	if (
		target_stack.item == source_stack.item
		and source_stack.item.is_stackable
	):

		var space: int = (
			source_stack.item.max_stack
			- target_stack.amount
		)

		if space <= 0:
			return

		var moved_amount: int = min(amount, space)

		target_stack.amount += moved_amount
		source_stack.amount -= moved_amount

		if source_stack.amount <= 0:
			inventory.items[from_slot] = null

		inventory.inventory_changed.emit(inventory.items)
		chest.inventory_changed.emit(chest.items)

		return


	# ---------------------------------------------------------
	# DIFFERENT ITEM
	# ---------------------------------------------------------

# =========================================================
# CHEST -> CHEST
# =========================================================

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

	var inventory_stack: InventoryStack = chest.get_stack(slot_index)

	if inventory_stack == null:
		var removed_item: ItemData = unequip_from_data(data)

		if removed_item == null:
			return

		chest.set_item(
			slot_index,
			removed_item
		)
		
		equipment.inventory_changed.emit(equipment.items)
		chest.inventory_changed.emit(chest.items)

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

	chest.set_item(
		slot_index,
		old_equipment_item
	)
	
	equipment.inventory_changed.emit(equipment.items)
	chest.inventory_changed.emit(chest.items)


func _drop_chest_item(data) -> void:

	if not data.has("chest"):
		return

	if not data.has("slot_index"):
		return

	var source_chest: ChestInventory = data["chest"]
	var source_slot: int = data["slot_index"]

	if source_chest == null:
		return

	if source_slot == slot_index and source_chest == chest:
		return

	var source_stack: InventoryStack = source_chest.get_stack(source_slot)

	if source_stack == null:
		return

	if source_chest == chest:

		var temp: InventoryStack = chest.items[slot_index]

		chest.items[slot_index] = chest.items[source_slot]
		chest.items[source_slot] = temp

		chest.inventory_changed.emit(chest.items)

		return


func _on_mouse_entered() -> void:
	if current_item == null:
		return

	if inventory != null:
		var hud = inventory.get_parent().get_node_or_null("../HUD")

		if hud:
			hud.show_item_tooltip(current_item)


func _on_mouse_exited() -> void:
	if inventory != null:
		var hud = inventory.get_parent().get_node_or_null("../HUD")

		if hud:
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
	
	inventory.add_item(current_item, current_amount)
	chest.remove_item(slot_index, current_amount)
	_on_mouse_exited()
	
	accept_event()


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
