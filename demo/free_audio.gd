extends AudioStreamPlayer3D
class_name FreeAudio3D

func _init(audio, vol=3.0, pitch_var=.2) -> void:
	stream = audio
	volume_db += vol
	pitch_scale = pitch_scale + randf_range(-pitch_var, 0)

func set_audio(audio, vol=3.0, pitch_var=.2):
	stream = audio
	volume_db += vol
	pitch_scale = pitch_scale + randf_range(-pitch_var, 0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	attenuation_filter_cutoff_hz = 20500
	finished.connect(_on_finished)
	self.play()
	pass # Replace with function body.



func _on_finished() -> void:
	queue_free()
	pass # Replace with function body.
