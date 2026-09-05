extends CanvasLayer

@onready var health_bar: ProgressBar = $Control/Stats/HealthBar
@onready var money_label: Label = $Control/Stats/MoneyLabel


func _ready() -> void:
	pass


func update_health(current_health: float, max_health: float) -> void:
	if health_bar == null:
		print("ERROR: health_bar is NULL")
		return
	
	health_bar.max_value = max_health
	health_bar.value = current_health


func update_money(money: int) -> void:
	money_label.text = "$%d" % money
