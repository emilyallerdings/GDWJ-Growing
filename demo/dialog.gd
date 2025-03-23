extends Panel

signal dialog_ended

@onready var label: RichTextLabel = $MarginContainer/PhoneText

var boss_prefix = "BOSS: "
var self_prefix = "* "
@export var dialog_1:Array[String] = []
@export var dialog_2:Array[String] = []
@export var dialog_3:Array[String] = []



var current_dialog:Array
var current_text_arr:Array
var current_text_idx = 0

var letter_dur = 0.05
var dialog_arr_num = 0
const PHONE_TEXT = preload("res://audio/phone_text.ogg")

var dialog_finished = false
var next_dialog = false

var speed_mod = 1.0
var can_speed = false

var speaker = "SELF"

var can_click = true

var testing = true

func get_phone_dia(num):
	if testing:
		return ["SELF", "..."]
	match num:
		1: return dialog_1
		2: return dialog_2
		3: return dialog_3
	return ["SELF", "..."]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NextDialog.visible = false
	self.visible = false
	next_dialog = false
	dialog_finished = true
	dialog_arr_num = 1
	pass # Replace with function body.

func play_dialog(dialog, num):
	if num == 0:
		num = 1
	
	if dialog.size() == 0:
		return
	
	can_click = false
	dialog_finished = false
	next_dialog = false
	
	#print(can_click)
	
	
	speaker = dialog[0]
	
	if speaker == "BOSS":
		label.text = boss_prefix
	elif speaker == "SELF":
		label.text = self_prefix
		
	current_dialog = dialog
	current_text_arr = current_dialog[num].split("")
	current_text_idx = 0
	speed_mod = 1.0
	self.visible = true
	$SpeedTimer.start()
	$LetterTimer.start(letter_dur)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_released():
		speed_mod = 1.0
	
	if event.is_pressed():
		if can_speed:
			speed_mod = 8.0
		
		if next_dialog && visible:
			
			$NextDialog.visible = false
			play_dialog(current_dialog, dialog_arr_num)
			
		if dialog_finished && visible:
			$NextDialog.visible = false
			self.visible = false
			print("can click false")
			await get_tree().create_timer(0.1).timeout
			print("can click true")
			can_click = true
		

func _on_letter_timer_timeout() -> void:
	var wait_dur = letter_dur + randf_range(-0.01, 0.01)
	var current_letter = current_text_arr[current_text_idx]
	var size_word = 0
	var line_size = 0
	for i in range(current_text_idx, current_text_arr.size()-1):
		if current_text_arr[i] == " ":
			break
		else:
			size_word += 1
	var label_text_arr = label.text.split("")
	for i in range(label_text_arr.size() - 1, 0, -1):
		if label_text_arr[i] == '\n':
			break
		else:
			line_size += 1
	
	#print("letters in line: ", line_size)
	
	if (line_size + size_word) * 18 > 1063:
		label.text += '\n'
	
	label.text += current_letter
	current_text_idx += 1
	
	if current_letter == " " || current_letter == ",":
		wait_dur = wait_dur + 0.02
	
	if current_letter == "." || current_letter == ":":
		wait_dur = wait_dur + 0.4
	
	if speaker == "BOSS":
		add_child(FreeAudioMono.new(PHONE_TEXT, max(-30 * speed_mod, -40), .25))
	
	if current_text_idx >= current_text_arr.size():
		dialog_arr_num += 1
		if dialog_arr_num >= current_dialog.size():
			$NextDialog.visible = true
			$NextDialog/AnimationPlayer.play("blink")
			next_dialog = false
			dialog_finished = true
			dialog_ended.emit()
			dialog_arr_num = 1
			return
		$NextDialog.visible = true
		$NextDialog/AnimationPlayer.play("blink")
		next_dialog = true
		return
	
	$LetterTimer.start(wait_dur/speed_mod)
	pass # Replace with function body.


func _on_speed_timer_timeout() -> void:
	can_speed = true
	pass # Replace with function body.
