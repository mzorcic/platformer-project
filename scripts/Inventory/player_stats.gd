extends Panel

var player: Node = null
var health_system: HealthSystem = null
var mana_system: ManaSystem = null
var equipment: Equipment = null
var resistance_system: ResistanceSystem = null

@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var mana_label: Label = $VBoxContainer/ManaLabel
@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var physical_label: Label = $VBoxContainer/PhysicalLabel
@onready var fire_label: Label = $VBoxContainer/FireLabel
@onready var ice_label: Label = $VBoxContainer/IceLabel
@onready var lightning_label: Label = $VBoxContainer/LightningLabel
@onready var poison_label: Label = $VBoxContainer/PoisonLabel
@onready var magic_label: Label = $VBoxContainer/MagicLabel


func setup(player_reference: Node) -> void:
	player = player_reference

	health_system = player.get_node_or_null("HealthSystem")
	mana_system = player.get_node_or_null("ManaSystem")
	equipment = player.get_node_or_null("Equipment")
	resistance_system = player.get_node_or_null("ResistanceSystem")

	if health_system:
		health_system.health_changed.connect(_on_health_changed)

	if mana_system:
		mana_system.mana_changed.connect(_on_mana_changed)

	if equipment:
		equipment.equipment_changed.connect(_on_equipment_changed)

	update_stats()


func update_stats() -> void:

	# -------------------------
	# HEALTH
	# -------------------------

	if health_system:
		health_label.text = "Health: %d / %d" % [
			roundi(health_system.current_health),
			roundi(health_system.max_health)
		]


	# -------------------------
	# MANA
	# -------------------------

	if mana_system:
		mana_label.text = "Mana: %d / %d\n" % [
			roundi(mana_system.current_mana),
			roundi(mana_system.max_mana)
		]
	
	if equipment.weapon != null:
		damage_label.text = ""
		if equipment.weapon.damage_parts.size() >= 0:
			for damage_part in equipment.weapon.damage_parts:
				if damage_part == null:
					damage_label.text = ""
		
				if damage_part.amount <= 0:
					continue
				
				match damage_part.damage_type:
					DamageSystem.DamageType.PHYSICAL:
						damage_label.text += "Physical Damage: %d\n" % damage_part.amount
				
					DamageSystem.DamageType.FIRE:
						damage_label.text += "Fire Damage: %d\n" % damage_part.amount
			
					DamageSystem.DamageType.ICE:
						damage_label.text += "Ice Damage: %d\n" % damage_part.amount
			
					DamageSystem.DamageType.LIGHTNING:
						damage_label.text += "Lightning Damage: %d\n" % damage_part.amount
			
					DamageSystem.DamageType.POISON:
						damage_label.text += "Poison Damage: %d\n" % damage_part.amount
			
					DamageSystem.DamageType.MAGIC:
						damage_label.text += "Magic Damage: %d\n" % damage_part.amount
	else:
		damage_label.text = "Physical Damage: %d\n" % player.BASE_ATTACK_DAMAGE
	
	
	# -------------------------
	# RESISTANCES
	# -------------------------

	if resistance_system:

		physical_label.text = "Physical: %d%%" % roundi(
			resistance_system.get_physical_resistance()
		)

		fire_label.text = "Fire: %d%%" % roundi(
			resistance_system.get_fire_resistance()
		)

		ice_label.text = "Ice: %d%%" % roundi(
			resistance_system.get_ice_resistance()
		)

		lightning_label.text = "Lightning: %d%%" % roundi(
			resistance_system.get_lightning_resistance()
		)

		poison_label.text = "Poison: %d%%" % roundi(
			resistance_system.get_poison_resistance()
		)

		magic_label.text = "Magic: %d%%" % roundi(
			resistance_system.get_magic_resistance()
		)


func _on_health_changed(_current: float, _maximum: float) -> void:
	update_stats()


func _on_mana_changed(_current: float, _maximum: float) -> void:
	update_stats()


func _on_equipment_changed() -> void:
	update_stats()
