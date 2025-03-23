extends CSGSphere3D

@export var flesh_ball:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AudioStreamPlayer3D.pitch_scale = 0.9 + 0.1 * flesh_ball.time_scale
	pass


func _on_audio_stream_player_3d_finished() -> void:
	$beat_time.start(0.8/(flesh_ball.time_scale*1.2))
	pass # Replace with function body.


func _on_beat_time_timeout() -> void:
	$AudioStreamPlayer3D.play()
	pass # Replace with function body.
