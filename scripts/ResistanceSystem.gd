class_name ResistanceSystem
extends Node

@export_category("Base Resistances")

@export var base_physical_resistance: float = 0.0
@export var base_fire_resistance: float = 0.0
@export var base_ice_resistance: float = 0.0
@export var base_lightning_resistance: float = 0.0
@export var base_poison_resistance: float = 0.0
@export var base_magic_resistance: float = 0.0


@onready var equipment: Equipment = get_parent().get_node_or_null("Equipment")


func get_physical_resistance() -> float:

	var resistance := base_physical_resistance

	if equipment != null:
		resistance += equipment.get_total_physical_resistance()

	return resistance


func get_fire_resistance() -> float:

	var resistance := base_fire_resistance

	if equipment != null:
		resistance += equipment.get_total_fire_resistance()

	return resistance


func get_ice_resistance() -> float:

	var resistance := base_ice_resistance

	if equipment != null:
		resistance += equipment.get_total_ice_resistance()

	return resistance


func get_lightning_resistance() -> float:

	var resistance := base_lightning_resistance

	if equipment != null:
		resistance += equipment.get_total_lightning_resistance()

	return resistance


func get_poison_resistance() -> float:

	var resistance := base_poison_resistance

	if equipment != null:
		resistance += equipment.get_total_poison_resistance()

	return resistance


func get_magic_resistance() -> float:

	var resistance := base_magic_resistance

	if equipment != null:
		resistance += equipment.get_total_magic_resistance()

	return resistance


func calculate_damage(damage: DamageSystem) -> float:

	var final_damage := damage.get_final_amount()

	match damage.damage_type:

		DamageSystem.DamageType.PHYSICAL:
			final_damage *= 1.0 - get_physical_resistance() / 100.0

		DamageSystem.DamageType.FIRE:
			final_damage *= 1.0 - get_fire_resistance() / 100.0

		DamageSystem.DamageType.ICE:
			final_damage *= 1.0 - get_ice_resistance() / 100.0

		DamageSystem.DamageType.LIGHTNING:
			final_damage *= 1.0 - get_lightning_resistance() / 100.0

		DamageSystem.DamageType.POISON:
			final_damage *= 1.0 - get_poison_resistance() / 100.0

		DamageSystem.DamageType.MAGIC:
			final_damage *= 1.0 - get_magic_resistance() / 100.0
	
	return max(final_damage, 0.0)
