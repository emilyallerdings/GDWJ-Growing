extends Node3D


@export var beat_delay:float = 2.0

func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	$AnimationPlayer.play("anim")
	$Timer.start(beat_delay)

func _on_audio_stream_player_finished() -> void:
	
	
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	$AudioStreamPlayer.play()
	$Timer.start(beat_delay)
	pass # Replace with function body.

func end():
	$AnimationPlayer.stop(true)
	$AudioStreamPlayer.volume_db = -80
	await get_tree().create_timer(1.0).timeout
	Transition.change_scene_to_menu()
	return
