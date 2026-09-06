class_name Equipment
extends Node

signal equipment_changed

var helmet: ItemData = null
var weapon: ItemData = null
var shield: ItemData = null
var boots: ItemData = null

var trinkets: Array[ItemData] = [
	null,
	null,
	null,
	null,
	null
]


func equip_helmet(item: ItemData) -> bool:

	if item == null:
		return false

	if item.equipment_type != ItemData.EquipmentType.HELMET:
		return false

	if helmet != null:
		return false

	helmet = item

	equipment_changed.emit()

	return true


func unequip_helmet() -> ItemData:

	if helmet == null:
		return null

	var old_item: ItemData = helmet

	helmet = null

	equipment_changed.emit()

	return old_item


func swap_helmet(item: ItemData) -> ItemData:

	if item == null:
		return null

	if item.equipment_type != ItemData.EquipmentType.HELMET:
		return null

	var old_item: ItemData = helmet

	helmet = item

	equipment_changed.emit()

	return old_item


func equip_weapon(item: ItemData) -> bool:

	if item == null:
		return false

	if item.equipment_type != ItemData.EquipmentType.WEAPON:
		return false

	if weapon != null:
		return false

	weapon = item

	equipment_changed.emit()

	return true


func unequip_weapon() -> ItemData:

	if weapon == null:
		return null

	var old_item: ItemData = weapon

	weapon = null

	equipment_changed.emit()

	return old_item


func swap_weapon(item: ItemData) -> ItemData:

	if item == null:
		return null

	if item.equipment_type != ItemData.EquipmentType.WEAPON:
		return null

	var old_item: ItemData = weapon

	weapon = item

	equipment_changed.emit()

	return old_item


func equip_shield(item: ItemData) -> bool:

	if item == null:
		return false

	if item.equipment_type != ItemData.EquipmentType.SHIELD:
		return false

	if shield != null:
		return false

	shield = item

	equipment_changed.emit()

	return true


func unequip_shield() -> ItemData:

	if shield == null:
		return null

	var old_item: ItemData = shield

	shield = null

	equipment_changed.emit()

	return old_item


func swap_shield(item: ItemData) -> ItemData:

	if item == null:
		return null

	if item.equipment_type != ItemData.EquipmentType.SHIELD:
		return null

	var old_item: ItemData = shield

	shield = item

	equipment_changed.emit()

	return old_item


func equip_boots(item: ItemData) -> bool:

	if item == null:
		return false

	if item.equipment_type != ItemData.EquipmentType.BOOTS:
		return false

	if boots != null:
		return false

	boots = item

	equipment_changed.emit()

	return true


func unequip_boots() -> ItemData:

	if boots == null:
		return null

	var old_item: ItemData = boots

	boots = null

	equipment_changed.emit()

	return old_item


func swap_boots(item: ItemData) -> ItemData:

	if item == null:
		return null

	if item.equipment_type != ItemData.EquipmentType.BOOTS:
		return null

	var old_item: ItemData = boots

	boots = item

	equipment_changed.emit()

	return old_item


func equip_trinket(slot_index: int, item: ItemData) -> bool:

	if item == null:
		return false

	if item.equipment_type != ItemData.EquipmentType.TRINKET:
		return false

	if slot_index < 0 or slot_index >= trinkets.size():
		return false

	if trinkets[slot_index] != null:
		return false

	trinkets[slot_index] = item

	equipment_changed.emit()

	return true


func unequip_trinket(slot_index: int) -> ItemData:

	if slot_index < 0 or slot_index >= trinkets.size():
		return null

	if trinkets[slot_index] == null:
		return null

	var old_item: ItemData = trinkets[slot_index]

	trinkets[slot_index] = null

	equipment_changed.emit()

	return old_item


func swap_trinket(slot_index: int, item: ItemData) -> ItemData:

	if item == null:
		return null

	if item.equipment_type != ItemData.EquipmentType.TRINKET:
		return null

	if slot_index < 0 or slot_index >= trinkets.size():
		return null

	var old_item: ItemData = trinkets[slot_index]

	trinkets[slot_index] = item

	equipment_changed.emit()

	return old_item


func get_all_equipped_items() -> Array[ItemData]:

	var equipped: Array[ItemData] = []

	if helmet != null:
		equipped.append(helmet)

	if weapon != null:
		equipped.append(weapon)

	if shield != null:
		equipped.append(shield)

	if boots != null:
		equipped.append(boots)

	for item in trinkets:

		if item != null:
			equipped.append(item)

	return equipped


func get_total_health_bonus() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.bonus_health

	return total


func get_total_mana_bonus() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.bonus_mana

	return total


func get_total_stamina_bonus() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.bonus_stamina

	return total


func get_weapon_damage_parts() -> Array[DamagePart]:
	var damage_parts: Array[DamagePart] = []

	if weapon == null:
		return damage_parts

	for damage_part in weapon.damage_parts:
		if damage_part != null:
			damage_parts.append(damage_part)

	return damage_parts


func get_total_physical_resistance() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.physical_resistance

	return total


func get_total_fire_resistance() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.fire_resistance

	return total


func get_total_ice_resistance() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.ice_resistance

	return total


func get_total_lightning_resistance() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.lightning_resistance

	return total


func get_total_poison_resistance() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.poison_resistance

	return total


func get_total_magic_resistance() -> float:

	var total := 0.0

	for item in get_all_equipped_items():

		if item != null:
			total += item.magic_resistance

	return total
