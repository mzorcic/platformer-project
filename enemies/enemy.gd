extends CharacterBody2D

const SPEED = 20.0
const FOLLOW_RANGE = 50.0
const ATTACK_COOLDOWN = 1.0
@export var attack_damage = 10.0
var player: Node2D
var attack_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if attack_timer > 0.0:
		attack_timer -= delta
	
	var distance:= global_position.distance_to(player.global_position)
	
	if distance <= FOLLOW_RANGE:
		var direction := global_position.direction_to(player.global_position)
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	if attack_timer <= 0.0:
		attack()
		attack_timer = ATTACK_COOLDOWN


func attack() -> void:
	var bodies: Array[Node2D] = $AttackArea.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player"):
			var damage := DamageSystem.new()
		
			damage.amount = attack_damage
			damage.damage_type = DamageSystem.DamageType.PHYSICAL
		
			var health_system = body.get_node_or_null("HealthSystem")
			if health_system == null:
				continue
			health_system.take_damage(damage)


func _on_died() -> void:
	player.get_node("MoneySystem").add_money(randf_range(10, 20))
	queue_free()
