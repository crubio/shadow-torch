extends Control

class_name Main

# Simple torch data container
class Torch:
	var id: int
	var name: String
	var total_seconds: float
	var remaining_seconds: float
	var is_lit: bool = true

	func _init(_id: int, _name: String, minutes: int = 6) -> void:
		id = _id
		name = _name
		total_seconds = float(minutes * 60)
		remaining_seconds = total_seconds
		is_lit = true

var torches: Array = [] # Array of Torch
var next_torch_id: int = 1

# Settings
var default_duration_minutes: int = 60 # in minutes
var default_units: String = "Minutes" # "Minutes", "Turns", "Hours"
var sound_alerts_enabled: bool = true

# UI References
var add_button: Button
var torch_list_container: VBoxContainer
var settings_button: Button

# Settings Panel References
var settings_panel: Control
var duration_spinbox: SpinBox
var units_option: OptionButton
var sound_checkbox: CheckBox
var close_button: Button
var apply_button: Button

func _ready() -> void:
	# Main UI references
	add_button = $MarginContainer/MainVBox/AddTorchButton
	torch_list_container = $MarginContainer/MainVBox/TorchList
	
	# Settings panel references
	settings_panel = $SettingsPanel
	duration_spinbox = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/DurationHBox/SpinBox
	units_option = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/UnitsHBox/OptionButton
	sound_checkbox = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/SoundHBox/CheckBox
	close_button = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/ButtonsHBox/CloseButton
	apply_button = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/ButtonsHBox/ApplyButton
	settings_button = $SettingsButton
	
	# Connect signals
	add_button.connect("pressed", Callable(self, "_on_add_torch_pressed"))
	close_button.connect("pressed", Callable(self, "_on_close_settings"))
	apply_button.connect("pressed", Callable(self, "_on_apply_settings"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	units_option.connect("item_selected", Callable(self, "_on_units_changed"))

	# Initialize settings panel
	_setup_settings_panel()
	settings_panel.visible = false
	
	# Add a sample torch
	_add_torch("Torch 1", default_duration_minutes)

func _process(delta: float) -> void:
	# Update remaining time for lit torches and refresh UI
	for t in torches:
		if t.is_lit:
			t.remaining_seconds = max(0.0, t.remaining_seconds - delta)
			if t.remaining_seconds <= 0.0:
				t.is_lit = false
				# TODO: emit a signal or play sound
	_refresh_ui()

func _on_add_torch_pressed() -> void:
	var duration = _get_duration_in_minutes()
	_add_torch("Torch %d" % next_torch_id, duration)

func _on_settings_pressed() -> void:
	show_settings()

func _add_torch(p_name: String, minutes: int = 6) -> void:
	var t = Torch.new(next_torch_id, p_name, minutes)
	next_torch_id += 1
	torches.append(t)
	_spawn_torch_item_ui(t)

func _spawn_torch_item_ui(t: Torch) -> void:
	var scene = load("res://scenes/torch_item.tscn")
	var item = scene.instantiate()
	item.torch_id = t.id
	torch_list_container.add_child(item)
	item.connect("request_extinguish", Callable(self, "_on_item_extinguish"))
	item.connect("request_remove", Callable(self, "_on_item_remove"))
	_update_item_display(item, t)

func _on_item_extinguish(torch_id: int) -> void:
	for t in torches:
		if t.id == torch_id:
			t.is_lit = not t.is_lit
			break

func _on_item_remove(torch_id: int) -> void:
	for i in range(torches.size()):
		if torches[i].id == torch_id:
			torches.remove_at(i)
			# remove UI node
			for child in torch_list_container.get_children():
				if child.has_method("get_torch_id") and child.get_torch_id() == torch_id:
					child.queue_free()
					break
			break

func _refresh_ui() -> void:
	for child in torch_list_container.get_children():
		if child.has_method("get_torch_id"):
			var id = child.get_torch_id()
			for t in torches:
				if t.id == id:
					_update_item_display(child, t)
					break

func _update_item_display(item: Node, t) -> void:
	if item.has_method("set_display"):
		item.set_display(t.name, t.remaining_seconds, t.is_lit, t.total_seconds, default_units)

# Settings Panel Functions
func _setup_settings_panel() -> void:
	# Set initial values
	duration_spinbox.value = default_duration_minutes
	units_option.selected = 0  # "Minutes" by default
	sound_checkbox.button_pressed = sound_alerts_enabled
	
	# Set button text
	close_button.text = "Close"
	apply_button.text = "Apply"
	
	var duration_label = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/DurationHBox/Label
	var units_label = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/UnitsHBox/Label  
	var sound_label = $SettingsPanel/ColorRect/CenterContainer/SettingsVBox/SoundHBox/Label
	
	duration_label.text = "Default Duration:"
	units_label.text = "Units:"
	sound_label.text = "Sound Alerts:"

func show_settings() -> void:
	settings_panel.visible = true

func hide_settings() -> void:
	settings_panel.visible = false

func _on_close_settings() -> void:
	hide_settings()

func _on_apply_settings() -> void:
	# Get values from UI
	default_duration_minutes = int(duration_spinbox.value)
	var selected_unit = units_option.get_item_text(units_option.selected)
	default_units = selected_unit
	sound_alerts_enabled = sound_checkbox.button_pressed
	
	# Apply settings logic here
	print("Settings applied - Duration: %d %s, Sound: %s" % [default_duration_minutes, default_units, sound_alerts_enabled])
	
	hide_settings()

func _get_duration_in_minutes() -> int:
	# Convert current settings to minutes
	match default_units:
		"Minutes":
			return default_duration_minutes
		"Turns":
			return default_duration_minutes * 10  # Shadowdark: 1 turn = 10 minutes
		"Hours":
			return default_duration_minutes * 60
		_:
			return default_duration_minutes  # fallback

func _on_units_changed(index: int) -> void:
	# Convert current duration value to new units
	var current_value = duration_spinbox.value
	var old_unit = default_units
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
	default_units = new_unit
	
	# Refresh all existing torch displays to show in new units
	_refresh_ui()
