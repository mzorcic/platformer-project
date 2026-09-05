extends CanvasLayer

# FIXED PATHS: Added the exact "O HUD/" prefix so Godot can find your folders!
# Quotation marks wrap up paths with spaces cleanly so the engine doesn't trip.
@onready var hp_bar_visual: Control = $"O HUD/Stats/HpBarVisual"
@onready var mana_bar: ProgressBar = $"O HUD/Stats/ManaBar"

# FIXED PATHS: Points safely inside your inventory folder structure
@onready var money_label: Label = get_node_or_null("O HUD/Inventory/MoneyLabel")
@onready var inventory_ui: Control = get_node_or_null("O HUD/Inventory")

# FIXED TYPE: Points directly to the green control node named "O HUD" for visibility toggles
@onready var hud: Control = $"O HUD"

var backpack_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Safely hide the inventory layout when the game boots up
	if inventory_ui != null:
		inventory_ui.visible = false
	
	# Find the player and initialize the health bar values on boot
	var player = get_node_or_null("../Player")
	if player:
		var health_system = player.get_node_or_null("HealthSystem")
		if health_system and hp_bar_visual != null:
			hp_bar_visual.init_health(health_system.current_health, health_system.max_health)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("backpack"):
		toggle_backpack()


func toggle_backpack() -> void:
	backpack_open = !backpack_open
	
	if inventory_ui != null:
		inventory_ui.visible = backpack_open
	if hud != null:
		hud.visible = !backpack_open
	
	if backpack_open:
		get_tree().paused = true
	else:
		get_tree().paused = false


func update_health(current_health: float, max_health: float) -> void:
	if hp_bar_visual != null:
		hp_bar_visual.update_health(current_health, max_health)


func update_mana(current_mana: float, max_mana: float) -> void:
	if mana_bar != null:
		mana_bar.max_value = max_mana
		mana_bar.value = current_mana


func update_money(money: int) -> void:
	if money_label != null:
		money_label.text = "$%d" % money
