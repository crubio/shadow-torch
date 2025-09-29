extends Control

signal request_extinguish(torch_id)
signal request_remove(torch_id)

var torch_id: int = -1

var name_label: Label
var time_label: Label
var ext_btn: Button
var rem_btn: Button
var panel_container: PanelContainer

func _ready() -> void:
	name_label = $PanelContainer/ContentHBox/NameLabel
	time_label = $PanelContainer/ContentHBox/TimeLabel
	ext_btn = $PanelContainer/ContentHBox/ExtinguishButton
	rem_btn = $PanelContainer/ContentHBox/RemoveButton
	panel_container = $PanelContainer
	ext_btn.connect("pressed", Callable(self, "_on_extinguish_pressed"))
	rem_btn.connect("pressed", Callable(self, "_on_remove_pressed"))

func get_torch_id() -> int:
	return torch_id

func set_display(p_name: String, remaining_seconds, is_lit: bool, total_seconds: float = 0.0, display_units: String = "Minutes") -> void:
	name_label.text = p_name
	
	# Format time based on display units
	var time_text = ""
	match display_units:
		"Minutes":
			var secs = int(remaining_seconds)
			var mm = int(secs / 60)
			var ss = secs % 60
			time_text = "%02d:%02d" % [mm, ss]
		"Turns":
			var turns = remaining_seconds / 600.0  # 600 seconds = 10 minutes = 1 turn
			time_text = "%.1f turns" % turns
		"Hours":
			var hours = remaining_seconds / 3600.0  # 3600 seconds = 1 hour
			time_text = "%.2f hrs" % hours
		_:
			# Fallback to minutes
			var secs = int(remaining_seconds)
			var mm = int(secs / 60)
			var ss = secs % 60
			time_text = "%02d:%02d" % [mm, ss]
	
	time_label.text = time_text
	ext_btn.text = ("extinguish" if is_lit else "relight")
	
	# Update background color based on torch status
	_update_torch_color(remaining_seconds, total_seconds, is_lit)

func _on_extinguish_pressed() -> void:
	emit_signal("request_extinguish", torch_id)

func _on_remove_pressed() -> void:
	emit_signal("request_remove", torch_id)

func _update_torch_color(remaining_seconds: float, total_seconds: float, is_lit: bool) -> void:
	# Create a StyleBoxFlat for the PanelContainer background
	var style_box = StyleBoxFlat.new()
	
	if not is_lit:
		# Extinguished - dark gray
		style_box.bg_color = Color(0.4, 0.4, 0.4, 0.8)
	elif total_seconds <= 0:
		# Fallback if no total provided
		style_box.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	else:
		# Calculate percentage remaining
		var percent_remaining = remaining_seconds / total_seconds
		
		if percent_remaining > 0.5:
			# Green - healthy (>50%)
			style_box.bg_color = Color(0.2, 0.8, 0.2, 0.6)
		elif percent_remaining > 0.1:
			# Yellow - getting low (10-50%)
			style_box.bg_color = Color(0.8, 0.8, 0.2, 0.6)
		else:
			# Red - critical (<10%)
			style_box.bg_color = Color(0.8, 0.2, 0.2, 0.6)
	
	# Apply the style to the PanelContainer
	panel_container.add_theme_stylebox_override("panel", style_box)
