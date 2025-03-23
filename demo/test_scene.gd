extends Node3D

var spheres:Dictionary = {}

func _ready() -> void:
	spheres[Vector3(0,0,0)] = 3
	$FleshBall.remesh()
