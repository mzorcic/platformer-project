extends Node

var max_health: float = 100.0
var current_health: float
var is_player_dead: bool = false

func _set_health_bar() -> void:
	$"../HealthBar".value = current_health

func _decrese_health(value) -> void:
	if current_health - value > 0.0:
		current_health = current_health - value
		_set_health_bar()
	elif current_health - value <= 0.0:
		current_health = 0.0
		_set_health_bar()
		_death()

func _death() -> void:
	current_health = max_health
	_set_health_bar()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	$"../HealthBar".max_value = max_health
	$"../HealthBar".value = current_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_key"):
		_decrese_health(20.0)
