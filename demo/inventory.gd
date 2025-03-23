extends HBoxContainer

signal deposit_flesh
signal pickup_flesh

var cur_sel = -1
var slots = []

var fill_slot = 0

var items = []
var can_swap = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items.resize(3)
	items.fill("")
	slots = get_children()
	set_cur_slot(0)
	print(slots)

	pass # Replace with function body.

func pick_up_item(item_name):
	fill_slot = -1
	for i in range(0,3):
		if slots[i].item == "":
			fill_slot = i
			break
	if fill_slot == -1:
		%Dialog.play_dialog(["SELF", "My hands are full."], 1)
		return false
		
	if item_name == "FLESH":
		pickup_flesh.emit()
	slots[fill_slot].set_item(item_name)
	if cur_sel == fill_slot:
		%ItemContainer.switch_to(slots[cur_sel].item)
	return true
func drop_item():

	slots[cur_sel].set_item("")
	%ItemContainer.switch_to(slots[cur_sel].item)

func set_cur_slot(num):
	if !can_swap:
		return
	if num == cur_sel:
		return
	cur_sel = num % slots.size()
	
	for i in range(slots.size()):
		slots[i].modulate.a = 100.0/255.0

	%ItemContainer.switch_to(slots[cur_sel].item)
	slots[cur_sel].modulate.a = 200.0/255.0
	

func _unhandled_input(event: InputEvent) -> void:
	if %Dialog.visible == true:
		return
	
	if Input.is_action_just_pressed("key_1"):
		set_cur_slot(0)
	if Input.is_action_just_pressed("key_2"):
		set_cur_slot(1)
	if Input.is_action_just_pressed("key_3"):
		set_cur_slot(2)
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		set_cur_slot(cur_sel+1)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		set_cur_slot(cur_sel-1)
