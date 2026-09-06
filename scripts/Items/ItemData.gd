class_name ItemData
extends Resource


enum EquipmentType {
	ITEM,
	HELMET,
	WEAPON,
	SHIELD,
	BOOTS,
	TRINKET
}


@export_category("Basic Information")
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D


@export_category("Equipment")
@export var equipment_type: EquipmentType = EquipmentType.ITEM


@export_category("Weapon Stats")
@export var damage_parts: Array[DamagePart] = []


@export_category("Player Stat Bonuses")
@export var bonus_health: float = 0.0
@export var bonus_mana: float = 0.0
@export var bonus_stamina: float = 0.0


@export_category("Resistance Bonuses")
@export var physical_resistance: float = 0.0
@export var fire_resistance: float = 0.0
@export var ice_resistance: float = 0.0
@export var lightning_resistance: float = 0.0
@export var poison_resistance: float = 0.0
@export var magic_resistance: float = 0.0


@export_category("Other")
@export var value: int = 0
