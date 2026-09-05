class_name ManaSystem
extends Node

signal mana_changed(current_mana: float, max_mana: float)

const MANA_REGEN_COOLDOWN: float = 2.0
@export var max_mana: float = 100.0
var current_mana: float = 0.0
var mana_regen_timer: float


func _ready() -> void:
	current_mana = max_mana
	await get_tree().process_frame
	mana_changed.emit(current_mana, max_mana)


func _physics_process(delta: float) -> void:
	if current_mana < max_mana:
		mana_regen_timer -= delta
		
		if mana_regen_timer <= 0.0:
			current_mana = min(current_mana + 10.0, max_mana)
			mana_changed.emit(current_mana, max_mana)
			
			print("regen mana")
			
			mana_regen_timer = MANA_REGEN_COOLDOWN


func use_mana(amount: float) -> bool:
	if current_mana < amount:
		print("Not enough mana!")
		return false
	
	current_mana -= amount
	print("Mana used")
	mana_regen_timer = MANA_REGEN_COOLDOWN
	
	mana_changed.emit(current_mana, max_mana)
	
	return true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_key"):
		use_mana(20)
