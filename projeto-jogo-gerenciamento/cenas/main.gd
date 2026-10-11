extends Node2D

@onready var timer_global: Timer = $"TimerGlobal"

func _ready() -> void:
	timer_global.timeout.connect(on_timer_global_timeout)
	

func on_timer_global_timeout():
	print('Pulso de 1 segundo!')
	get_tree().call_group("plantas", "acumular_tempo")
