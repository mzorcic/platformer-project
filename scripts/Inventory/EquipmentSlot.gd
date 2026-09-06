class_name EquipmentSlot
extends Panel

@onready var item_icon: TextureRect = $ItemIcon

@export var equipment_index: int = 0

var equipment: Equipment = null
var inventory: Inventory = null
var item_data: ItemData = null


func set_item(item: ItemData) -> void:

	item_data = item

	if item == null:
		item_icon.texture = null
		return

	item_icon.texture = item.icon


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


	return {
		"source": "equipment",
		"equipment_index": equipment_index,
		"equipment_type": _get_equipment_type(),
		"item": current_item,
		"equipment_slot": self
	}
