extends Node3D

var office_door_open = false
var chamber_door_open = false

var force_close = false

func reset_doors():
	$AirlockDoor.play("RESET")
	office_door_open = false
	chamber_door_open = false
	force_close = false
	

func open_office_door():
	$AirlockDoor.play("open_office_door")
	$OfficeDoor.play_audio(0)
	office_door_open = true
	
func close_office_door():
	$AirlockDoor.play_backwards("open_office_door")
	$OfficeDoor.play_audio(1)
	office_door_open = false
	
func open_chamber_door():
	$AirlockDoor.play("open_chamber_door")
	$ChamberDoor.play_audio(0)
	chamber_door_open = true
	
func close_chamber_door():
	$AirlockDoor.play_backwards("open_chamber_door")
	$ChamberDoor.play_audio(1)
	chamber_door_open = false
