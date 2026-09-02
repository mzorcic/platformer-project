extends CharacterBody2D

const SPEED = 100.0


func _ready() -> void:
	add_to_group("player")


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
	var bodies: Array[Node2D] = $AttackArea.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("enemy"):
			var damage := DamageSystem.new()
		
			damage.amount = 25.0
			damage.damage_type = DamageSystem.DamageType.PHYSICAL
		
			var health_system = body.get_node_or_null("HealthSystem")
			if health_system == null:
				continue
			health_system.take_damage(damage)


func _on_died() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://screens/DiedScene.tscn")


func _on_health_system_health_changed(current_health: float, max_health: float) -> void:
	var health_bar = $HealthBar
	health_bar.max_value = max_health
	health_bar.value = current_health
