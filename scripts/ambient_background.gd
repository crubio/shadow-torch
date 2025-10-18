extends TextureRect

var shader_material: ShaderMaterial
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader_material = material as ShaderMaterial # material that is applied to this canvas
	
	# Hook up to LightManager
	LightManager.light_changed.connect(_on_light_changed)
	LightManager.light_extinguished.connect(_on_light_extinguished)
	
	pass # Replace with function body.

func _on_light_changed(light_data) -> void:
	if not shader_material:
		return
	print("ambient_bg called: on_light_changed")
	
func _on_light_extinguished() -> void:
	print("ambient_bg called: on_light_extinguished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
