class_name HealthSystem
extends Node

signal health_changed(current_health:float, max_health:float)
signal damaged(amount:float)
signal healed(amount:float)
signal died

@export var max_health: float = 100.0

var current_health: float
var is_dead: bool = false

@onready var resistance_system: ResistanceSystem = get_parent().get_node_or_null("ResistanceSystem")


func _ready() -> void:
	current_health = max_health
	await get_tree().process_frame
	health_changed.emit(current_health, max_health)


func take_damage(damage: DamageSystem) -> void:
	if is_dead:
		return
	
	if damage == null:
		return
	
	var final_damage := damage.get_final_amount()
	
	if resistance_system != null:
		final_damage = resistance_system.calculate_damage(damage)
	
	current_health -= final_damage
	
	current_health = max(current_health, 0.0)
	
	damaged.emit(final_damage)
	print(final_damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0.0:
		die()


func heal(amount: float) -> void:
	if is_dead:
		return
	
	if amount <= 0:
		return
	
	var old_health := current_health
	current_health += amount
	current_health = min(current_health, max_health)
	
	var actual_healing := current_health - old_health
	
	if actual_healing > 0.0:
		healed.emit(actual_healing)
		health_changed.emit(current_health, max_health)


func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	died.emit()
