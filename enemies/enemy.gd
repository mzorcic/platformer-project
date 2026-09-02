extends CharacterBody2D

const SPEED = 70.0
const FOLLOW_RANGE = 70.0
const ATTACK_RANGE = 20.0
const COOLDOWN = 1.0
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
	
	if distance <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		if attack_timer <= 0.0:
			attack()
			attack_timer = COOLDOWN


func attack() -> void:
	var damage := DamageSystem.new()
		
	damage.amount = attack_damage
	damage.damage_type = DamageSystem.DamageType.PHYSICAL
		
	var health_system = player.get_node("HealthSystem")
	health_system.take_damage(damage)


func _on_died() -> void:
	queue_free()
