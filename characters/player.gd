extends CharacterBody2D

const SPEED = 100.0
const BASE_ATTACK_DAMAGE := 25.0
const ATTACK_COOLDOWN := 0.5

var attack_timer: float = 0.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_cone: Polygon2D = $AttackArea/AttackCone
@onready var hud = $"../HUD"
@onready var health_system: HealthSystem = $HealthSystem
@onready var mana_system: ManaSystem = $ManaSystem
@onready var money_system: MoneySystem = $MoneySystem
@onready var inventory: Inventory = $Inventory
@onready var equipment: Equipment = $Equipment
@onready var resistance_system: ResistanceSystem = $ResistanceSystem



func _ready() -> void:
	add_to_group("player")
	health_system.health_changed.connect(hud.update_health)
	money_system.money_changed.connect(hud.update_money)
	mana_system.mana_changed.connect(hud.update_mana)
	inventory.inventory_changed.connect(hud.update_inventory)
	equipment.equipment_changed.connect(_on_equipment_changed)
	
	await get_tree().process_frame
	
	hud.setup_inventory_slots(inventory, equipment)
	hud.setup_equipment_slots(equipment, inventory)


func get_movement_input():
	var input_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = input_direction * SPEED


func _physics_process(delta: float) -> void:
	get_movement_input()
	move_and_slide()
	
	if attack_timer > 0.0:
		attack_timer -= delta


func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position
	
	attack_area.rotation = direction.angle()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack()
	if event.is_action_pressed("test_key"):
		var test_item: ItemData = preload("res://items/RingOfHealth.tres")
		inventory.add_item(test_item)
	if event.is_action_pressed("test_key_2"):
		var test_item: ItemData = preload("res://items/IronSword.tres")
		inventory.add_item(test_item)


func attack() -> void:
	if attack_timer > 0.0:
		return

	attack_timer = ATTACK_COOLDOWN

	var attack_angle: float = deg_to_rad(120.0)

	var bodies: Array[Node2D] = attack_area.get_overlapping_bodies()

	var hit_enemies: Array[Node] = []

	for body in bodies:
		if not body.is_in_group("enemy"):
			continue

		if body in hit_enemies:
			continue

		var direction_to_enemy: Vector2 = body.global_position - global_position

		var angle_to_enemy: float = abs(
			attack_area.global_rotation - direction_to_enemy.angle()
		)

		if angle_to_enemy > PI:
			angle_to_enemy = TAU - angle_to_enemy

		if angle_to_enemy > attack_angle / 2.0:
			continue

		var enemy_health: HealthSystem = body.get_node_or_null("HealthSystem") as HealthSystem

		if enemy_health == null:
			continue

		hit_enemies.append(body)

		# Weapon equipped
		if equipment.weapon != null:

			for damage_part in equipment.get_weapon_damage_parts():

				var damage := DamageSystem.new()

				damage.amount = damage_part.amount
				damage.damage_type = damage_part.damage_type

				enemy_health.take_damage(damage)

		# No weapon
		else:
			var damage := DamageSystem.new()

			damage.amount = BASE_ATTACK_DAMAGE
			damage.damage_type = DamageSystem.DamageType.PHYSICAL

			enemy_health.take_damage(damage)


func _on_died() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://screens/DiedScene.tscn")


func _on_equipment_changed() -> void:
	health_system.update_equipment_bonuses()
	mana_system.update_equipment_bonuses()
