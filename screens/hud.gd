extends CanvasLayer

@onready var health_bar: ProgressBar = $HUD/Stats/DamageBar/HealthBar
@onready var damage_bar: ProgressBar = $HUD/Stats/DamageBar
@onready var mana_bar: ProgressBar = $HUD/Stats/ManaBar
@onready var money_label: Label = $Inventory/MoneyLabel
@onready var hud: Control = $HUD
@onready var inventory_ui: Control = $Inventory

var health_tween: Tween
var damage_tween: Tween
var backpack_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_ui.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("backpack"):
		toggle_backpack()


func toggle_backpack() -> void:
	backpack_open = !backpack_open
	
	inventory_ui.visible = backpack_open
	hud.visible = !backpack_open
	
	if backpack_open:
		get_tree().paused = true
	else:
		get_tree().paused = false


func update_health(current_health: float, max_health: float) -> void:
	if health_bar == null or damage_bar == null:
		return

	health_bar.max_value = max_health
	damage_bar.max_value = max_health

	if health_tween:
		health_tween.kill()
	
	if damage_tween:
		damage_tween.kill()
	
	health_tween = create_tween()
	
	health_tween.tween_property(
		health_bar,
		"value",
		current_health,
		1.0
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	damage_tween = create_tween()
	
	damage_tween.tween_interval(0.25)
	
	damage_tween.tween_property(
		damage_bar,
		"value",
		current_health,
		0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func update_mana(current_mana: float, max_mana: float) -> void:
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana


func update_money(money: int) -> void:
	money_label.text = "$%d" % money
