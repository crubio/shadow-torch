extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer

var _light_is_active: bool = false

func _ready() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.self_modulate = Color(1, 1, 1, 0)  # Start invisible

	LightManager.light_changed.connect(_on_light_changed)
	LightManager.light_extinguished.connect(_on_light_extinguished)

func _on_light_changed(light_data: Dictionary) -> void:
	_light_is_active = light_data.active  # Check if light is actually active
	
	if not _light_is_active:
		return
	
	var animation_name: String

	match light_data.type:
		LightManager.LightType.TORCH:
			color_rect.self_modulate = Color(0.98, 0.82, 0.42, color_rect.self_modulate.a)
			animation_name = "torch_flicker"
		
		LightManager.LightType.LIGHT_SPELL:
			color_rect.self_modulate = Color(0.59, 0.44, 0.84, color_rect.self_modulate.a)
			animation_name = "light_pulse"

	# Only play if not already playing this animation
	if animation_player.current_animation != animation_name:
		print("Starting animation: ", animation_name)
		animation_player.play(animation_name)

func _on_light_extinguished(msg: String) -> void:
	_light_is_active = false
	# Stop the animation
	animation_player.stop()
	print("Animation stopped")
	
	# Manually reset ColorRect to invisible
	color_rect.self_modulate = Color(1, 1, 1, 0)
	print("ColorRect self_modulate set to: ", color_rect.self_modulate)
