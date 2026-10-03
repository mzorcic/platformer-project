class_name Chest
extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var chest_inventory: ChestInventory = $ChestInventory

@export var loot_table: ChestLootTable

var player_nearby: bool = false
var player: Node = null
var loot_generated: bool = false


func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		player = body

		var hud = get_tree().get_first_node_in_group("hud")

		if hud != null:
			hud.show_interaction_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_nearby = false
		player = null

		var hud = get_tree().get_first_node_in_group("hud")

		if hud != null:
			hud.hide_interaction_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby:
		return

	if event.is_action_pressed("interact"):
		open_chest()
		get_viewport().set_input_as_handled()


func open_chest() -> void:

	print("OPEN CHEST CALLED")

	if not loot_generated:
		generate_loot()

	var hud = get_tree().get_first_node_in_group("hud")

	if hud == null:
		print("ERROR: HUD NOT FOUND!")
		return

	hud.open_chest(self)


func generate_loot() -> void:
	if loot_generated:
		return
	
	if loot_table == null:
		return
	
	if loot_table.loot_table == null:
		return
	
	var table: LootTable = loot_table.loot_table
	
	loot_generated = true
	
	# -------------------------
	# COMMON
	# -------------------------
	
	for i in range(loot_table.guaranteed_common_items):
		var item := get_random_item(table.common_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	
	# -------------------------
	# UNCOMMON
	# -------------------------
	
	for i in range(loot_table.guaranteed_uncommon_items):
		var item := get_random_item(table.uncommon_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	if randf() < loot_table.uncommon_chance:
		var item := get_random_item(table.uncommon_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	
	# -------------------------
	# RARE
	# -------------------------
	
	for i in range(loot_table.guaranteed_rare_items):
		var item := get_random_item(table.rare_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	if randf() < loot_table.rare_chance:
		var item := get_random_item(table.rare_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	
	# -------------------------
	# EPIC
	# -------------------------
	
	for i in range(loot_table.guaranteed_epic_items):
		var item := get_random_item(table.epic_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	if randf() < loot_table.epic_chance:
		var item := get_random_item(table.epic_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	
	# -------------------------
	# LEGENDARY
	# -------------------------
	
	for i in range(loot_table.guaranteed_legendary_items):
		var item := get_random_item(table.legendary_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	if randf() < loot_table.legendary_chance:
		var item := get_random_item(table.legendary_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	
	# -------------------------
	# MYTHICAL
	# -------------------------
	
	for i in range(loot_table.guaranteed_mythical_items):
		var item := get_random_item(table.mythical_items)
		
		if item != null:
			chest_inventory.add_item(item)
	
	if randf() < loot_table.mythical_chance:
		var item := get_random_item(table.mythical_items)
		
		if item != null:
			chest_inventory.add_item(item)


func get_random_item(items: Array[ItemData]) -> ItemData:
	if items.is_empty():
		return null

	return items[randi() % items.size()]
