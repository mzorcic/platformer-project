class_name ResistanceSystem
extends Node

@export_category("Resistances")

@export_range(0.0, 1.0, 0.1) var physical_resistance: float = 0.0
@export_range(0.0, 1.0, 0.1) var fire_resistance: float = 0.0
@export_range(0.0, 1.0, 0.1) var ice_resistance: float = 0.0
@export_range(0.0, 1.0, 0.1) var lightning_resistance: float = 0.0


func get_resistance(damage_type: DamageSystem.DamageType) -> float:
	match  damage_type:
		DamageSystem.DamageType.PHYSICAL:
			return physical_resistance
		DamageSystem.DamageType.FIRE:
			return fire_resistance
		DamageSystem.DamageType.ICE:
			return ice_resistance
		DamageSystem.DamageType.LIGHTNING:
			return lightning_resistance
	return 0.0


func calculate_damage(damage: DamageSystem) -> float:
	if damage == null:
		return 0.0
	
	var base_damage: float = damage.get_final_amount()
	var resistance: float = get_resistance(damage.damage_type)
	var final_damage: float = base_damage * (1.0 - resistance)
	
	return max(final_damage, 0.0)
