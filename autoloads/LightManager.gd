# res://autoloads/LightManager.gd
extends Node

# Light source types
enum LightType { TORCH, LIGHT_SPELL }

# Light source signals
signal light_changed(light_data: Dictionary)
signal light_warning(percentage: float, message: String)
signal light_extinguished(message: String)
signal light_timer_updated(remaining_seconds: float)

# Party light state
var party_light: Dictionary = {
	"active": false,
	"type": LightType,
	"source_name": "",
	"total_seconds": 3600.0,  # Always 60 minutes per Shadowdark rules
	"remaining_seconds": 3600.0,
	"alerted_25": false,
	"alerted_10": false,
	"alerted_0": false,
	"is_lit": false
}

var _last_tracked_state: Dictionary = {
  "active": false,
  "type": -1,
  "is_lit": false
}

var _last_tracked_seconds: int = -1

func _emit_on_change() -> void:
	var current_state = {
		"active": party_light.active,
		"type": party_light.type,
		"is_lit": party_light.is_lit
	}
  
	if current_state != _last_tracked_state:
		_last_tracked_state = current_state
		light_changed.emit(party_light)
		print("light_changed emitted - active: %s, type: %s, is_lit: %s" % [current_state.active, current_state.type, current_state.is_lit])

func _ready() -> void:
	# Connect to game loop - process will be called from main scene
	pass

func light_torch() -> bool:
	return _start_light_source(LightType.TORCH)

func cast_light_spell() -> bool:
	return _start_light_source(LightType.LIGHT_SPELL)

func _start_light_source(type: LightType) -> bool:
	if party_light.active:
		return false  # Light already active - caller should handle replacement
	
	_create_light_source(type)
	return true

func _create_light_source(type: LightType) -> void:
	var source_name = _get_light_source_name(type)
	var duration_seconds = GameSettings.default_duration_minutes * 60.0
	
	party_light = {
		"active": true,
		"type": type,
		"source_name": source_name,
		"total_seconds": duration_seconds,
		"remaining_seconds": duration_seconds,
		"alerted_25": false,
		"alerted_10": false,
		"alerted_0": false,
		"is_lit": true
	}

	_emit_on_change()
	print("Party lit a " + source_name.to_lower() + "!")

func extinguish_light() -> void:
	if party_light.active:
		party_light.active = false
		party_light.is_lit = false
		light_extinguished.emit("The " + party_light.source_name.to_lower() + " has been extinguished.")
		_emit_on_change()

func replace_light_source(type: LightType) -> void:
	extinguish_light()
	_create_light_source(type)

func update_light(delta: float) -> void:
	if not party_light.active:
		return
		
	_check_light_percentage()
	
	party_light.remaining_seconds = max(0.0, party_light.remaining_seconds - delta)
	
	if party_light.active:
		light_timer_updated.emit(party_light.remaining_seconds)
	
	if party_light.remaining_seconds <= 0.0:
		party_light.active = false
		party_light.is_lit = false
		light_extinguished.emit("DARKNESS ARISES! You are in danger!")
		light_extinguished.emit("The " + party_light.source_name.to_lower() + " has burned out.")

	_emit_on_change()

func _check_light_percentage() -> void:
	var percentage_left = party_light.remaining_seconds / party_light.total_seconds
	
	if percentage_left <= 0.0 and not party_light.alerted_0:
		light_warning.emit(0.0, "DARKNESS ARISES! You are in danger!")
		party_light.alerted_0 = true
		
	elif percentage_left <= 0.10 and not party_light.alerted_10:
		light_warning.emit(10.0, party_light.source_name + " is about to die!")
		party_light.alerted_10 = true
		
	elif percentage_left <= 0.25 and not party_light.alerted_25:
		light_warning.emit(25.0, party_light.source_name + " is burning low!")
		party_light.alerted_25 = true

func _get_light_source_name(type: LightType) -> String:
	match type:
		LightType.TORCH:
			return "Torch"
		LightType.LIGHT_SPELL:
			return "Light"
		_:
			return "Unknown"

func get_party_light_data() -> Dictionary:
	return party_light.duplicate()

func is_party_light_active() -> bool:
	return party_light.active

func get_light_percentage() -> float:
	if party_light.total_seconds <= 0:
		return 0.0
	return party_light.remaining_seconds / party_light.total_seconds
