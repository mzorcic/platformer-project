extends Control

@onready var fill_container: Control = $FillContainer
@onready var green_bar: TextureRect = $FillContainer/BlackBg/GreenBar
@onready var red_bar: TextureRect = $FillContainer/BlackBg/RedBar

# Fallback reference: If it cannot find $HpNumber directly, it looks anywhere inside the scene for it
@onready var hp_number: Label = $HpNumber if has_node("HpNumber") else get_node_or_null("Border/HpNumber")

var damage_tween: Tween
var max_width: float = 0.0

func _ready() -> void:
	# Capture the full default layout frame width dynamically 
	max_width = fill_container.size.x
	
	if hp_number == null:
		# Ultimate search loop to find your text label by class type if names mismatch
		for child in get_children():
			if child is Label:
				hp_number = child
				break

func init_health(current_hp: float, max_hp: float) -> void:
	var health_ratio = clamp(current_hp / max_hp, 0.0, 1.0)
	
	# Prime the initial starting horizontal bar fill states
	green_bar.size.x = health_ratio * max_width
	red_bar.size.x = green_bar.size.x
	
	# Prime the text display indicator value inside our heart logo frame
	if hp_number != null:
		hp_number.text = str(ceil(current_hp))

func update_health(current_hp: float, max_hp: float) -> void:
	var health_ratio = clamp(current_hp / max_hp, 0.0, 1.0)
	var target_width = health_ratio * max_width
	
	# Update the bold string indicator instantly right on hit register events
	if hp_number != null:
		hp_number.text = str(ceil(current_hp))
	
	var is_healing: bool = target_width > green_bar.size.x
	
	if is_healing:
		if damage_tween and damage_tween.is_running():
			damage_tween.kill()
		green_bar.size.x = target_width
		red_bar.size.x = target_width
	else:
		# Instantly drop the foreground green bar health marker state width
		green_bar.size.x = target_width
		
		if damage_tween and damage_tween.is_running():
			damage_tween.kill()
			
		# Animate the red bar sliding down to catch up after our small deliberate delay frame
		damage_tween = create_tween()
		damage_tween.tween_interval(0.25)
		damage_tween.tween_property(red_bar, "size:x", target_width, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
