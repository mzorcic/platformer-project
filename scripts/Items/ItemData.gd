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

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	MYTHICAL
}


@export_category("Basic Information")
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D


@export_category("Stacking")
@export var is_stackable: bool = true
@export_range(1, 999) var max_stack: int = 10


@export_category("Equipment")
@export var rarity: Rarity = Rarity.COMMON
@export var equipment_type: EquipmentType = EquipmentType.ITEM
@export var is_usable: bool = false


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


@export_category("Healing")
@export var healing: float = 0.0
@export var regen_mana: float = 0.0


@export_category("Other")
@export var value: int = 0
