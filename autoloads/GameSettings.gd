# res://autoloads/GameSettings.gd
extends Node

# Settings signals
signal settings_changed

# Settings properties
var default_duration_minutes: int = 60
var default_units: String = "Minutes"  # "Minutes", "Turns", "Hours"
var sound_alerts_enabled: bool = true

# Settings file path
const SETTINGS_FILE = "user://settings.save"

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		var settings_data = {
			"default_duration_minutes": default_duration_minutes,
			"default_units": default_units,
			"sound_alerts_enabled": sound_alerts_enabled
		}
		file.store_string(JSON.stringify(settings_data))
		file.close()
		print("Settings saved")

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var settings_data = json.data
				default_duration_minutes = settings_data.get("default_duration_minutes", 60)
				default_units = settings_data.get("default_units", "Minutes")
				sound_alerts_enabled = settings_data.get("sound_alerts_enabled", true)
				print("Settings loaded")
			else:
				print("Error parsing settings file")

func update_settings(duration: int, units: String, sound_enabled: bool) -> void:
	default_duration_minutes = duration
	default_units = units
	sound_alerts_enabled = sound_enabled
	save_settings()
	settings_changed.emit()