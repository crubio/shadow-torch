extends Node2D

signal request_extinguish()

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	start_pulse_animation()

func start_pulse_animation() -> void:
	if animation_player and animation_player.has_animation("pulse"):
		animation_player.play("pulse")

func update_time_display(_current_time: String, _total_time: String) -> void:
	# Light spells don't need time display - they're magical!
	pass
