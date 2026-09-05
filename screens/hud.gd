extends CanvasLayer

@onready var health_bar: ProgressBar = $HUD/Stats/HealthBar
@onready var mana_bar: ProgressBar = $HUD/Stats/ManaBar
@onready var money_label: Label = $Inventory/MoneyLabel
@onready var hud: Control = $HUD
@onready var inventory_ui: Control = $Inventory

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
	health_bar.max_value = max_health
	health_bar.value = current_health


func update_mana(current_mana: float, max_mana: float) -> void:
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana


func update_money(money: int) -> void:
	money_label.text = "$%d" % money
