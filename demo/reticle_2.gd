extends CenterContainer

@export var character : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_reticle(1)
	pass # Replace with function body.


func set_reticle(num):
	for child in get_children():
		child.visible = false
	get_children()[num].visible = true
