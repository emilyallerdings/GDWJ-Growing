extends Node3D



func start_p(audio:bool = true):
	if audio:
		$AudioStreamPlayer3D.play()
	$GrinderParticles.emitting = true
	$GrinderParticles2.emitting = true
	await get_tree().create_timer(1.2).timeout
	$GrinderParticles.emitting = false
	$GrinderParticles2.emitting = false
