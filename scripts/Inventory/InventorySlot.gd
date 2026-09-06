extends Panel

@onready var item_icon: TextureRect = $ItemIcon

var slot_index: int = -1
var inventory: Inventory = null
var equipment: Equipment = null
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


func _get_drag_data(_at_position: Vector2):
	if item_data == null:
		return null
	
	var preview := TextureRect.new()
	
	preview.texture = item_data.icon
	preview.custom_minimum_size = Vector2(50, 50)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	set_drag_preview(preview)
	
	return {
		"source": "inventory",
		"slot_index": slot_index,
		"item": item_data
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
		return data.has("slot_index")
	
	if data["source"] == "equipment":
		
		if not data.has("equipment_type"):
			return false
		
		return true
	
	return false


func _drop_data(_at_position: Vector2, data) -> void:
	if inventory == null:
		print("ERROR: Inventory reference is NULL!")
		return
	
	if data["source"] == "inventory":
	
		var from_slot: int = data["slot_index"]
		
		if from_slot == slot_index:
			return
		
		print(
			"Swapping inventory slots ",
			from_slot,
			" and ",
			slot_index
		)
		
		inventory.move_item(from_slot, slot_index)
		
		return
	
	if data["source"] == "equipment":
		
		if equipment == null:
			print("ERROR: Equipment reference is NULL!")
			return
		
		var equipment_type: ItemData.EquipmentType = data["equipment_type"]
		var equipment_item: ItemData = data["item"]
		
		if equipment_item == null:
			return
		
		var inventory_item: ItemData = inventory.get_item(slot_index)
		
		if inventory_item == null:
			
			var removed_item: ItemData = null
			
			if equipment_type == ItemData.EquipmentType.WEAPON:
				
				removed_item = equipment.unequip_weapon()
			
			elif equipment_type == ItemData.EquipmentType.TRINKET:
				
				var trinket_index: int = data["trinket_index"]
				
				removed_item = equipment.unequip_trinket(
					trinket_index
				)
			
			if removed_item == null:
				return
			
			inventory.set_item(
				slot_index,
				removed_item
			)
			
			print(
				"Moved ",
				removed_item.item_name,
				" from equipment to inventory."
			)
			
			return
		
		if inventory_item.equipment_type != equipment_type:
			
			print(
				"Cannot swap: ",
				inventory_item.item_name,
				" cannot go into this equipment slot."
			)
			
			return
		
		var old_equipment_item: ItemData = null
		
		if equipment_type == ItemData.EquipmentType.WEAPON:
			
			old_equipment_item = equipment.swap_weapon(
				inventory_item
			)
		
		elif equipment_type == ItemData.EquipmentType.TRINKET:
			
			var trinket_index: int = data["trinket_index"]
			
			old_equipment_item = equipment.swap_trinket(
				trinket_index,
				inventory_item
			)
		
		if old_equipment_item == null:
			return
		
		inventory.set_item(
			slot_index,
			old_equipment_item
		)
		
		print(
			"Swapped equipment item ",
			old_equipment_item.item_name,
			" with ",
			inventory_item.item_name
		)
