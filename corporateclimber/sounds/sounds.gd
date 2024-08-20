extends Node3D

@export var random_sounds: Array[AudioStreamPlayer3D]



func _on_timer_timeout() -> void:
	random_sounds.pick_random().play()
