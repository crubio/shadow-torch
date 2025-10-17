extends Node2D  # or Node2D if that's what you used

signal request_extinguish()

@onready var icon_sprite = $Icon  # Adjust to your actual node names
@onready var point_light = $PointLight2D
@onready var particles = $CPUParticles2D
@onready var animate = $AnimatedSprite2D

# Add a label for time display if you want
@onready var time_label: Label

func _ready() -> void:
	# Start the torch animation/effects
	_start_torch_effects()
	
	# If you have an extinguish button, connect it
	# $ExtinguishButton.connect("pressed", Callable(self, "_on_extinguish_pressed"))

func _start_torch_effects() -> void:
	# Enable particles
	if particles:
		particles.emitting = true
	
	# Set light properties
	if point_light:
		point_light.enabled = true
		point_light.energy = 0.8
		point_light.color = Color(1.0, 0.9, 0.7)  # Warm torch color
		
	animate.play("start_burning")

func _stop_torch_effects() -> void:
	if particles:
		particles.emitting = false
	if point_light:
		point_light.enabled = false

func update_time_display(current_time: String, total_time: String) -> void:
	if time_label:
		time_label.text = "%s / %s" % [current_time, total_time]

func _on_extinguish_pressed() -> void:
	emit_signal("request_extinguish")
