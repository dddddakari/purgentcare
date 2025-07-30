# Save this as a singleton/autoload 
# if it doesnt already save, Maxim :3
# should control music everywhere so just add buttons
extends Node

signal music_toggled(is_muted: bool)

var is_music_muted = false
var speaker_on_texture = preload("res://assets/button/SPEAKER_ON.PNG")
var speaker_off_texture = preload("res://assets/button/SPEAKER_OFF.PNG")

func toggle_music():
	is_music_muted = !is_music_muted
	music_toggled.emit(is_music_muted)
	print("Music ", "muted" if is_music_muted else "unmuted")

func set_audio_stream_state(audio_stream: AudioStreamPlayer2D):
	if is_music_muted:
		audio_stream.stop()
	else:
		if not audio_stream.playing:
			audio_stream.play()

func get_speaker_texture():
	return speaker_off_texture if is_music_muted else speaker_on_texture
