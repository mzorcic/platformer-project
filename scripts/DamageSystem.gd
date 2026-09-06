class_name DamageSystem
extends Resource

enum DamageType {
	PHYSICAL,
	FIRE,
	ICE,
	LIGHTNING,
	POISON,
	MAGIC
	}


@export var amount: float = 0.0
@export var damage_type: DamageType = DamageType.PHYSICAL


func get_final_amount() -> float:
	return amount
