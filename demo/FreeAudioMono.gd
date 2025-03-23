extends AudioStreamPlayer
class_name FreeAudioMono

func _init(audio, vol = 0, pitch_var= .1):
	self.stream = audio
	volume_db += vol
	pitch_scale = pitch_scale + randf_range(-pitch_var,pitch_var)
	
func _ready() -> void:
	self.play()
	finished.connect(_finished)
	
func _finished():
	self.queue_free()
