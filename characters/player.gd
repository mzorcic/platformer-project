extends CharacterBody2D

const SPEED = 100.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_cone: Polygon2D = $AttackArea/AttackCone
@onready var hud = $"../HUD"
@onready var health_system: HealthSystem = $HealthSystem
@onready var mana_system: ManaSystem = $ManaSystem
@onready var money_system: MoneySystem = $MoneySystem

const ATTACK_RANGE := 20.0
const ATTACK_ANGLE := 120.0


func _ready() -> void:
	add_to_group("player")
	health_system.health_changed.connect(hud.update_health)
	money_system.money_changed.connect(hud.update_money)
	mana_system.mana_changed.connect(hud.update_mana)
	create_attack_cone()


func get_movement_input():
	var input_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = input_direction * SPEED


func _physics_process(delta: float) -> void:
	get_movement_input()
	move_and_slide()


func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position
	
	attack_area.rotation = direction.angle()


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack"):
		attack()


func attack() -> void:
	var attack_angle := deg_to_rad(120.0)
	
	var bodies := attack_area.get_overlapping_bodies()
	
	for body in bodies:
		if not body.is_in_group("enemy"):
			continue
		
		var direction_to_enemy := body.global_position - global_position
		
		var angle_to_enemy = abs(
			attack_area.global_rotation - direction_to_enemy.angle()
		)
		
		if angle_to_enemy > PI:
			angle_to_enemy = TAU - angle_to_enemy
		
		if angle_to_enemy > attack_angle / 2.0:
			continue
		
		var health_system = body.get_node_or_null("HealthSystem")
		
		if health_system == null:
			continue
		
		var damage := DamageSystem.new()
		damage.amount = 25.0
		damage.damage_type = DamageSystem.DamageType.PHYSICAL
		
		health_system.take_damage(damage)


func _on_died() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://screens/DiedScene.tscn")


func create_attack_cone() -> void:
	var points := PackedVector2Array()
	
	points.append(Vector2.ZERO)
	
	var segments := 30
	var half_angle := deg_to_rad(ATTACK_ANGLE / 2.0)
	
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var angle := -half_angle + (ATTACK_ANGLE * t * PI / 180.0)
		
		var point := Vector2.RIGHT.rotated(angle) * ATTACK_RANGE
		points.append(point)
	
	attack_cone.polygon = points
