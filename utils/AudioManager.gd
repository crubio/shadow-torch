# res://utils/AudioManager.gd

# Access anywhere: AudioManager.play_sound_effect("alert")
extends Node

var alert_sound: AudioStreamPlayer
var success_sound: AudioStreamPlayer
var failure_sound: AudioStreamPlayer

func _ready() -> void:
	# TODO: Replace with actual sound files
	alert_sound = AudioStreamPlayer.new()
	alert_sound.stream = preload("res://alert.wav")
	add_child(alert_sound)

	success_sound = AudioStreamPlayer.new()
	success_sound.stream = preload("res://alert.wav")
	add_child(success_sound)

	failure_sound = AudioStreamPlayer.new()
	failure_sound.stream = preload("res://alert.wav")
	add_child(failure_sound)

func play_sound_effect(sound_name: String) -> void:
	match sound_name:
		"alert":
			alert_sound.play()
		"success":
			success_sound.play()
		"failure":
			failure_sound.play()
		_:
			alert_sound.play()  # Default to alert sound
