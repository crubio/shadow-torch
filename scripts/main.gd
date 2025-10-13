extends Control

class_name Main

var _pending_light_type: LightManager.LightType

# UI References
var party_light_container: VBoxContainer
var settings_button: Button
var torch_tracker: Label
var light_torch_button: Button
var cast_light_spell_button: Button
var replace_dialog: ConfirmationDialog

# Light source tracking
var duration_spinbox: SpinBox
var units_option: OptionButton
var sound_checkbox: CheckBox
var close_button: Button
var apply_button: Button

func _ready() -> void:
	print("Main scene ready")
	# Main UI references
	torch_tracker = $MarginContainer/MainVBox/TorchTracker
	light_torch_button = $MarginContainer/MainVBox/LightTorchButton
	cast_light_spell_button = $MarginContainer/MainVBox/CastLightSpellButton
	party_light_container = $MarginContainer/MainVBox/PartyLight
	replace_dialog = $ReplaceLightSourceDialog

	# Settings panel references
	duration_spinbox = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/DurationHBox/SpinBox
	units_option = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/UnitsHBox/OptionButton
	sound_checkbox = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/SoundHBox/CheckBox
	close_button = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/ButtonsHBox/CloseButton
	apply_button = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/ButtonsHBox/ApplyButton
	settings_button = $SettingsButton
	
	# Connect signals
	light_torch_button.connect("pressed", Callable(self, "_on_light_torch_pressed"))
	cast_light_spell_button.connect("pressed", Callable(self, "_on_cast_light_spell_pressed"))
	replace_dialog.connect("confirmed", Callable(self, "_on_replace_light_confirmed"))
	close_button.connect("pressed", Callable(self, "_on_close_settings"))
	apply_button.connect("pressed", Callable(self, "_on_apply_settings"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	units_option.connect("item_selected", Callable(self, "_on_units_changed"))
	
	# Connect to LightManager signals
	LightManager.light_changed.connect(_on_light_changed)
	LightManager.light_warning.connect(_on_light_warning)
	LightManager.light_extinguished.connect(_on_light_extinguished)

	# Initialize settings panel
	_setup_settings_panel()
	
	_update_party_display()

func _process(delta: float) -> void:
	# Let LightManager handle the timing and alerts
	LightManager.update_light(delta)

func _on_light_torch_pressed() -> void:
	if LightManager.is_party_light_active():
		_pending_light_type = LightManager.LightType.TORCH
		replace_dialog.dialog_text = "The party already has a light source. Do you want to replace it with a torch?"
		replace_dialog.popup_centered()
	else:
		LightManager.light_torch()
	
func _on_cast_light_spell_pressed() -> void:
	if LightManager.is_party_light_active():
		_pending_light_type = LightManager.LightType.LIGHT_SPELL
		replace_dialog.dialog_text = "The party already has a light source. Do you want to replace it with a light spell?"
		replace_dialog.popup_centered()
	else:
		LightManager.cast_light_spell()

func _on_replace_light_confirmed() -> void:
	LightManager.replace_light_source(_pending_light_type)
	update_notifications("The party has replaced their light source.")

# LightManager signal handlers
func _on_light_changed(_light_data: Dictionary) -> void:
	_update_party_display()

func _on_light_warning(_percentage: float, message: String) -> void:
	update_notifications(message)
	play_alert_sound()

func _on_light_extinguished(message: String) -> void:
	update_notifications(message)
	_update_party_display()

func _update_party_display() -> void:
	# Update the main status label
	if LightManager.party_light.active:
		var time_string = TimeFormatter.format_time(LightManager.party_light.remaining_seconds, GameSettings.default_units)
		torch_tracker.text = "Party has about " + time_string + " of " + LightManager.party_light.source_name.to_lower() + " left."
		
		# Update the party light container with current light source info
		_update_party_light_container()
	else:
		torch_tracker.text = "Party has no light source."
		_clear_party_light_container()

func _update_party_light_container() -> void:
	# Clear existing content
	_clear_party_light_container()
	
	if LightManager.party_light.active:
		# Create a label showing the current light source details
		var light_info_label = Label.new()
		var time_string = TimeFormatter.format_time(LightManager.party_light.remaining_seconds, GameSettings.default_units)
		var total_time = TimeFormatter.format_time(LightManager.party_light.total_seconds, GameSettings.default_units)
		
		light_info_label.text = "%s: %s / %s" % [LightManager.party_light.source_name, time_string, total_time]
		light_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		party_light_container.add_child(light_info_label)

func _clear_party_light_container() -> void:
	# Remove all children from the party light container
	for child in party_light_container.get_children():
		child.queue_free()

func play_alert_sound() -> void:
	if GameSettings.sound_alerts_enabled:
		AudioManager.play_sound_effect("alert")

func update_notifications(message: String) -> void:
	var notification_label = $Notifications
	notification_label.text = message
	notification_label.visible = true
	print("Notification: " + message)

func _on_settings_pressed() -> void:
	show_settings()

# Settings Panel Functions
func _setup_settings_panel() -> void:
	# Load settings from GameSettings
	GameSettings.load_settings()
	
	# Set button text
	close_button.text = "Close"
	apply_button.text = "Apply"
	
	# Set label text
	var duration_label = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/DurationHBox/Label
	var units_label = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/UnitsHBox/Label  
	var sound_label = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/SoundHBox/Label
	
	duration_label.text = "Default Duration:"
	units_label.text = "Units:"
	sound_label.text = "Sound Alerts:"
	
	# Populate UI controls with current GameSettings values
	duration_spinbox.value = GameSettings.default_duration_minutes
	sound_checkbox.button_pressed = GameSettings.sound_alerts_enabled
	
	# Set the units dropdown to the correct value
	var unit_options = ["Minutes", "Turns", "Hours"]
	for i in range(unit_options.size()):
		if unit_options[i] == GameSettings.default_units:
			units_option.selected = i
			break

func show_settings() -> void:
	var settings_panel = $SettingsPanel
	var color_rect = $SettingsPanel/ColorRect
	
	if settings_panel:
		settings_panel.visible = true
		settings_panel.z_index = 10
	
	if color_rect:
		color_rect.visible = true

func hide_settings() -> void:
	var settings_panel = $SettingsPanel
	var color_rect = $SettingsPanel/ColorRect
	
	if settings_panel:
		settings_panel.visible = false
	if color_rect:
		color_rect.visible = false

func _on_close_settings() -> void:
	hide_settings()

func _on_apply_settings() -> void:
	# Get values from UI
	var selected_unit = units_option.get_item_text(units_option.selected)
	GameSettings.update_settings(int(duration_spinbox.value), selected_unit, sound_checkbox.button_pressed)
	
	# Apply settings logic here
	print("Settings applied - New torch duration: %d %s, Sound: %s" % [GameSettings.default_duration_minutes, GameSettings.default_units, GameSettings.sound_alerts_enabled])
	
	# Show user notification about settings
	if LightManager.is_party_light_active():
		update_notifications("Settings saved. New duration (%d %s) will apply to next torch." % [GameSettings.default_duration_minutes, GameSettings.default_units])
	else:
		update_notifications("Settings saved. Next torch will last %d %s." % [GameSettings.default_duration_minutes, GameSettings.default_units])
	
	# Refresh the display to show existing torch in new units
	_update_party_display()
	
	hide_settings()

func _on_units_changed(index: int) -> void:
	# Convert current duration value to new units
	var current_value = duration_spinbox.value
	var old_unit = GameSettings.default_units
	var new_unit = units_option.get_item_text(index)
	
	# Convert current value to minutes first
	var minutes = 0.0
	match old_unit:
		"Minutes":
			minutes = current_value
		"Turns":
			minutes = current_value * 10
		"Hours":
			minutes = current_value * 60
		_:
			minutes = current_value
	
	# Convert minutes to new unit
	var new_value = 0.0
	match new_unit:
		"Minutes":
			new_value = minutes
		"Turns":
			new_value = minutes / 10.0
		"Hours":
			new_value = minutes / 60.0
		_:
			new_value = minutes
	
	# Update the spinbox value and internal tracking
	duration_spinbox.value = max(1.0, new_value)  # Don't allow values less than 1
	GameSettings.default_units = new_unit
