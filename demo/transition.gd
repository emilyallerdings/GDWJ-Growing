extends CanvasLayer

var num = 1
const FLESH_PARTICLES_2 = preload("res://FleshParticles2.tscn")
const BLOOD_DRIP = preload("res://blood_drip.tscn")
const MAIN_MENU = preload("res://main_menu.tscn")

func _ready() -> void:
	$Sprite2D.visible = false

func change_scene(target:PackedScene):
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	$Sprite2D.visible = true
	$Label.visible = true
	Engine.time_scale = 8.0
	$Label.text = "LOADING: 1/4"
	
	$SubViewport/FleshParticles.emitting = true
	await $SubViewport/FleshParticles.finished
	
	$Label.text = "LOADING: 2/4"
	var n_particle = FLESH_PARTICLES_2.instantiate()
	$SubViewport.add_child(n_particle)
	await  n_particle.finished
	
	$Label.text = "LOADING: 3/4"
	n_particle = BLOOD_DRIP.instantiate()
	$SubViewport.add_child(n_particle)
	await n_particle.finished
	
	$Label.text = "LOADING: 4/4"
	$SubViewport/GrinderParts.start_p(false)
	await get_tree().create_timer(4).timeout
	
	
	$Sprite2D.visible = false
	Engine.time_scale = 1.0
	$Label.visible = false
	get_tree().change_scene_to_packed(target)
	await get_tree().create_timer(1.5).timeout
	
	$AnimationPlayer.play_backwards("dissolve")

func change_scene_to_menu():
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(MAIN_MENU)
	$AnimationPlayer.play_backwards("dissolve")
