class_name ChestLootTable
extends Resource

@export var loot_table: LootTable

@export_category("Guaranteed Loot")
@export var guaranteed_common_items: int = 2
@export var guaranteed_uncommon_items: int = 0
@export var guaranteed_rare_items: int = 0
@export var guaranteed_epic_items: int = 0
@export var guaranteed_legendary_items: int = 0
@export var guaranteed_mythical_items: int = 0

@export_category("Extra Loot Chances")
@export_range(0.0, 1.0) var uncommon_chance: float = 0.25
@export_range(0.0, 1.0) var rare_chance: float = 0.05
@export_range(0.0, 1.0) var epic_chance: float = 0.0
@export_range(0.0, 1.0) var legendary_chance: float = 0.0
@export_range(0.0, 1.0) var mythical_chance: float = 0.0
