extends Panel

@onready var item_name: Label = $VBoxContainer/ItemName
@onready var item_type: Label = $VBoxContainer/ItemType
@onready var description: Label = $VBoxContainer/Description
@onready var damage: Label = $VBoxContainer/Damage
@onready var stats: Label = $VBoxContainer/Stats
@onready var value: Label = $Value


func show_item(item: ItemData) -> void:
	if item == null:
		hide()
		return

	item_name.text = item.item_name
	
	set_item_type_text(item.rarity, item.equipment_type)

	description.text = item.description + "\n"
	
	if item.damage_parts.size() >= 0:
		for damage_part in item.damage_parts:
			if damage_part == null:
				damage.text = ""
		
			if damage_part.amount <= 0:
				continue
		
			match damage_part.damage_type:
				DamageSystem.DamageType.PHYSICAL:
					damage.text += "Physical Damage: %d\n" % damage_part.amount
				
				DamageSystem.DamageType.FIRE:
					damage.text += "Fire Damage: %d\n" % damage_part.amount
			
				DamageSystem.DamageType.ICE:
					damage.text += "Ice Damage: %d\n" % damage_part.amount
			
				DamageSystem.DamageType.LIGHTNING:
					damage.text += "Lightning Damage: %d\n" % damage_part.amount
			
				DamageSystem.DamageType.POISON:
					damage.text += "Poison Damage: %d\n" % damage_part.amount
			
				DamageSystem.DamageType.MAGIC:
					damage.text += "Magic Damage: %d\n" % damage_part.amount
	if item.healing > 0.0:
		damage.text += "Healing: %d\n" % item.healing
	
	if item.regen_mana > 0.0:
		damage.text += "Mana Regeneration: %d\n" % item.regen_mana
	
	if item.bonus_health != 0:
		stats.text += "Health: +%d\n" % item.bonus_health

	if item.bonus_mana != 0:
		stats.text += "Mana: +%d\n" % item.bonus_mana
	
	if item.physical_resistance != 0:
		stats.text += "Physical Resistance: +" + str(item.physical_resistance) + "%\n"
	
	if item.fire_resistance != 0:
		stats.text += "Fire Resistance: +" + str(item.fire_resistance) + "%\n" 
	
	if item.ice_resistance != 0:
		stats.text += "Ice Resistance: +" + str(item.ice_resistance) + "%\n"
	
	if item.lightning_resistance != 0:
		stats.text += "Lightning Resistance: +" + str(item.lightning_resistance) + "%\n"
	
	if item.poison_resistance != 0:
		stats.text += "Poison Resistance: +" + str(item.poison_resistance) + "%\n"
	
	if item.magic_resistance != 0:
		stats.text += "Magic Resistance: +" + str(item.magic_resistance) + "%\n"
	
	value.text = str(item.value) + " Gold"
	
	show()


func hide_tooltip() -> void:
	damage.text = ""
	stats.text = ""
	hide()

func set_item_type_text(rarity: ItemData.Rarity, type: ItemData.EquipmentType):
	
	var rarity_text: String
	var type_text: String
	
	match rarity:
		ItemData.Rarity.COMMON:
			rarity_text = "Common"
		ItemData.Rarity.UNCOMMON:
			rarity_text = "Uncommon"
		ItemData.Rarity.RARE:
			rarity_text = "Rare"
		ItemData.Rarity.EPIC:
			rarity_text = "Epic"
		ItemData.Rarity.LEGENDARY:
			rarity_text = "Legendary"
		ItemData.Rarity.MYTHICAL:
			rarity_text = "Mythical"
	
	match type:
		ItemData.EquipmentType.ITEM:
			type_text = "Item"
		ItemData.EquipmentType.HELMET:
			type_text = "Helmet"
		ItemData.EquipmentType.WEAPON:
			type_text = "Weapon"
		ItemData.EquipmentType.SHIELD:
			type_text = "Shield"
		ItemData.EquipmentType.BOOTS:
			type_text = "Boots"
		ItemData.EquipmentType.TRINKET:
			type_text = "Trinket"
	
	item_type.text = rarity_text + " " + type_text + "\n"
