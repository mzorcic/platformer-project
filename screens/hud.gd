extends CanvasLayer

@onready var equipment_slots = [
	$Inventory/BackpackPanel/EquipmentPanel/HelmetSlot,
	$Inventory/BackpackPanel/EquipmentPanel/WeaponSlot,
	$Inventory/BackpackPanel/EquipmentPanel/ShieldSlot,
	$Inventory/BackpackPanel/EquipmentPanel/BootsSlot,
	$Inventory/BackpackPanel/EquipmentPanel/EquipmentSlot1,
	$Inventory/BackpackPanel/EquipmentPanel/EquipmentSlot2,
	$Inventory/BackpackPanel/EquipmentPanel/EquipmentSlot3,
	$Inventory/BackpackPanel/EquipmentPanel/EquipmentSlot4,
	$Inventory/BackpackPanel/EquipmentPanel/EquipmentSlot5
]

@onready var health_bar: ProgressBar = $HUD/Stats/DamageBar/HealthBar
@onready var health_label: Label = $HUD/Stats/DamageBar/HealthBar/HealthLabel
@onready var damage_bar: ProgressBar = $HUD/Stats/DamageBar
@onready var mana_bar: ProgressBar = $HUD/Stats/ManaBar
@onready var money_label: Label = $Inventory/MoneyLabel
@onready var hud: Control = $HUD
@onready var inventory_ui: Control = $Inventory
@onready var inventory_grid: GridContainer = $Inventory/BackpackPanel/InventoryPanel/InventoryGrid
@onready var player_inventory: Inventory = $"../Player/Inventory"
@onready var item_tooltip = $Inventory/BackpackPanel/ItemTooltip
@onready var interaction_prompt = $HUD/InteractionPrompt
@onready var chest_panel = $ChestPanel
@onready var chest_inventory = $ChestPanel/ChestBackground/ChestGrid

var equipment: Equipment = null
var health_tween: Tween
var damage_tween: Tween
var backpack_open: bool = false
var current_chest = null
var chest_open: bool = false


func _ready() -> void:
	add_to_group("hud")
	process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_ui.visible = false
	hide_item_tooltip()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("backpack"):
		toggle_backpack()
	if event.is_action_pressed("ui_cancel"):
		close_current_ui()


func toggle_backpack() -> void:
	backpack_open = !backpack_open
	
	inventory_ui.visible = backpack_open
	hud.visible = !backpack_open
	
	if backpack_open:
		get_tree().paused = true
	else:
		get_tree().paused = false


func close_current_ui() -> void:

	if chest_open:
		close_chest()
		return

	elif backpack_open:
		toggle_backpack()
		return


func update_health(current_health: float, max_health: float) -> void:
	if health_bar == null or damage_bar == null:
		return

	health_bar.max_value = max_health
	damage_bar.max_value = max_health
	health_label.text = "%d / %d" % [current_health, max_health]
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
	money_label.text = str(money) + " Gold"


func update_inventory(items: Array) -> void:
	var slots = inventory_grid.get_children()

	for i in range(slots.size()):
		if i < items.size() and items[i] != null:
			slots[i].set_item(
				items[i].item,
				items[i].amount
			)
		else:
			slots[i].clear_slot()


func setup_inventory_slots(	player_inventory_a: Inventory, player_equipment: Equipment) -> void:

	var slots = inventory_grid.get_children()

	for i in range(slots.size()):
		slots[i].slot_index = i
		slots[i].inventory = player_inventory_a
		slots[i].equipment = player_equipment


func setup_equipment_slots(player_equipment: Equipment, player_inventory_b: Inventory) -> void:

	equipment = player_equipment

	for slot in equipment_slots:
		slot.equipment = player_equipment
		slot.inventory = player_inventory_b

	equipment.equipment_changed.connect(update_equipment)

	update_equipment()


func update_equipment() -> void:

	if equipment == null:
		return

	# Helmet
	equipment_slots[0].set_item(
		equipment.helmet
	)

	# Weapon
	equipment_slots[1].set_item(
		equipment.weapon
	)

	# Shield
	equipment_slots[2].set_item(
		equipment.shield
	)

	# Boots
	equipment_slots[3].set_item(
		equipment.boots
	)

	# Equipment slots / Trinkets
	for i in range(equipment.trinkets.size()):

		equipment_slots[i + 4].set_item(
			equipment.trinkets[i]
		)


func show_item_tooltip(item: ItemData) -> void:
	item_tooltip.show_item(item)


func hide_item_tooltip() -> void:
	item_tooltip.hide_tooltip()


func show_interaction_prompt() -> void:
	if chest_open:
		return
	
	interaction_prompt.visible = true


func hide_interaction_prompt() -> void:
	interaction_prompt.visible = false


func open_chest(chest) -> void:
	
	chest_open = true
	inventory_ui.visible = true
	hud.visible = false

	chest_panel.visible = true

	chest_inventory = chest.chest_inventory

	setup_chest_slots(chest_inventory)

	chest_inventory.inventory_changed.connect(
		update_chest_inventory
	)

	update_chest_inventory(chest_inventory.items)

	get_tree().paused = true


func close_chest() -> void:
	current_chest = null
	chest_panel.visible = false
	chest_open = false
	inventory_ui.visible = false
	hud.visible = true
	get_tree().paused = false


func setup_chest_slots(chest: ChestInventory) -> void:

	var slots = $ChestPanel/ChestBackground/ChestGrid.get_children()

	print("Found chest slots: ", slots.size())

	for i in range(slots.size()):

		var slot: ChestSlot = slots[i]

		slot.slot_index = i
		slot.chest = chest
		slot.inventory = player_inventory

	print("Chest slots setup complete.")


func update_chest_inventory(items: Array) -> void:

	var slots = $ChestPanel/ChestBackground/ChestGrid.get_children()

	for i in range(slots.size()):

		if i < items.size() and items[i] != null:

			slots[i].set_item(
				items[i].item,
				items[i].amount
			)

		else:

			slots[i].clear_slot()
