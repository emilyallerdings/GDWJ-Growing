extends Control

const MAIN = preload("res://main.tscn")
@onready var h_slider: HSlider = $OptionsControl/HBoxContainer/HSlider

var started = false

func _ready() -> void:
	get_tree().paused = false
	var bus_index = AudioServer.get_bus_index("Master")
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	h_slider.value_changed.connect(_on_h_slider_value_changed)

func _on_start_button_pressed() -> void:
	if started:
		return
	started = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Transition.change_scene(MAIN)


func _on_options_button_pressed() -> void:
	if started:
		return
	$AnimationPlayer.play("fade_main")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards("fade_control")
		
	



func _on_back_button_pressed() -> void:
	if started:
		return
	$AnimationPlayer.play("fade_control")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards("fade_main")
	return


func _on_check_box_toggled(toggled_on: bool) -> void:
	if started:
		return
	Globals.clamp_mouse_speed = toggled_on
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	if started:
		return
	get_tree().quit()
	pass # Replace with function body.



func _on_h_slider_value_changed(value: float) -> void:
	print("changed")
	$TestAudio.play()
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(h_slider.value ))
	pass # Replace with function body.
