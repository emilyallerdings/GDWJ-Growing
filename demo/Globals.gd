extends Node


var mouse_speed_clamp = 154
var mouse_speed_clamp_sqr = 154*154
var clamp_mouse_speed = true

func set_mouse_speed_clamp(speed):
	mouse_speed_clamp = speed
	mouse_speed_clamp_sqr = mouse_speed_clamp * mouse_speed_clamp
	
