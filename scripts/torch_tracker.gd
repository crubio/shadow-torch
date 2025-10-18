extends Label
# Script to intercept the signals from LightManager that happen every second.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LightManager.light_timer_updated.connect(_on_light_timer_updated)
	pass # Replace with function body.


func _on_light_timer_updated(remaining_seconds: float) -> void:
	var minutes = int(remaining_seconds) / 60
	var seconds = int(remaining_seconds) % 60
	text = "%02d:%02d" % [minutes, seconds]
