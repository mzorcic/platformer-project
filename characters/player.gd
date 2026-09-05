extends CharacterBody2D

const SPEED = 100.0


@onready var hud = $"../HUD"
@onready var health_system: HealthSystem = $HealthSystem
@onready var money_system: MoneySystem = $MoneySystem


func _ready() -> void:
	add_to_group("player")
	health_system.health_changed.connect(hud.update_health)
	money_system.money_changed.connect(hud.update_money)


func get_movement_input():
	var input_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = input_direction * SPEED


func _physics_process(delta: float) -> void:
	get_movement_input()
	move_and_slide()


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack"):
		attack()


func attack() -> void:
	var attack_range := 20.0
	var attack_angle := 120.0
	var damage_amount := 25.0
	
	var mouse_position := get_global_mouse_position()
	var attack_direction := (mouse_position - global_position).normalized()
	
	for body in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(body):
			continue
		
		var distance := global_position.distance_to(body.global_position)
		
		# Enemy is too far away
		if distance > attack_range:
			continue
		
		var direction_to_enemy = (body.global_position - global_position).normalized()
		
		# Angle between where we're facing and the enemy
		var angle := rad_to_deg(attack_direction.angle_to(direction_to_enemy))
		
		# Outside the attack cone
		if abs(angle) > attack_angle / 2.0:
			continue
		
		# Enemy is inside the sweeping attack
		var health_system = body.get_node_or_null("HealthSystem")
		
		if health_system == null:
			continue
		
		var damage := DamageSystem.new()
		damage.amount = damage_amount
		damage.damage_type = DamageSystem.DamageType.PHYSICAL
		
		health_system.take_damage(damage)


func _on_died() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://screens/DiedScene.tscn")
