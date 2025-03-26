extends Node3D
class_name Main

var spheres:Dictionary = {}
const BLOOD_PARTICLES = preload("res://blood_drip.tscn")
@onready var shovel_parent: Node3D = $Character/Head/ItemContainer/ShovelParent
@onready var shovel: Node3D = $Character/Head/ItemContainer/ShovelParent/Shovel
@onready var shovel_anim: AnimationPlayer = $Character/Head/ItemContainer/ShovelParent/Shovel/ShovelAnim
const INJECTION = preload("res://injection.tscn")
var cur_hover = null
const INJECT = preload("res://audio/inject.ogg")
const FLESH = preload("res://flesh.tscn")
const ENDINGSCENE = preload("res://endingscene.tscn")
var bus_index = AudioServer.get_bus_index("Reverb")

var phone_ringing = false
var total_vol:float
var cur_vol:float
var scanning = false
var beep_delay = 3.0
var fleshies = []
var paused = false
var flesh_remaining = -1

var first_time_pickup = true
var first_time_process = true
var to_inject = 0
var char_start
var week = 1

var airlock_office_open = false

var total_fleshies = 1

var can_leave = false

func pause():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$PauseMenu.visible = true
	paused = true
	get_tree().paused = true

func unpause():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$PauseMenu.visible = false
	paused = false
	get_tree().paused = false

func _on_focus_exited():
	pause()

func _set_high_quality_flesh(num):
	if $FleshBall.end_seq:
		$%FleshMass.visible = false
		%FleshToFind.visible = false
		%ObjectiveLabel.obj_kill()
		%Ring.global_position.y -= 10
		return
	can_leave = false
	var space_state = get_world_3d().direct_space_state

	fleshies.clear()
	flesh_remaining = num
	to_inject = num
	await get_tree().physics_frame
	
	for i in range(0, num):
		var g_pos = $FleshBall.to_global($FleshBall.get_random_pos_in_surface())
		var query = PhysicsRayQueryParameters3D.create(g_pos, Vector3(g_pos.x, g_pos.y + 15, g_pos.z), 256)
		query.hit_from_inside = true
		var result = space_state.intersect_ray(query)
		#print(result)
		while result || g_pos.y > 2:
			
			g_pos = $FleshBall.to_global($FleshBall.get_random_pos_in_surface())
			query = PhysicsRayQueryParameters3D.create(g_pos, Vector3(g_pos.x, g_pos.y + 15, g_pos.z),256)
			query.hit_from_inside = true
			result = space_state.intersect_ray(query)
			#print(result)
		print(g_pos)
		var n_flesh = FLESH.instantiate()
		add_child(n_flesh)
		
		n_flesh.global_position = g_pos
		fleshies.append(n_flesh)
		
func _ready() -> void:
	%ObjectiveLabel.visible = false
	%FleshMass.visible = false
	%FleshToFind.visible = false
	
	AudioServer.set_bus_mute(0, true)
	$LoadingTransition/AnimationPlayer.play("dissolve")
	await $LoadingTransition/AnimationPlayer.animation_finished
	char_start = $Character.global_transform
	
	spheres[Vector3(0,0,0)] = 3
	$FleshBall.remesh()
	
	total_vol =  $FleshBall.get_volume()
	cur_vol = total_vol
	_set_high_quality_flesh(1)
	%ObjectiveLabel.obj_find()
	
	$LoadingTransition/AnimationPlayer.play_backwards("dissolve")
	AudioServer.set_bus_mute(0, false)
	await $LoadingTransition/AnimationPlayer.animation_finished
	if $FleshBall.end_seq:
		week = 4
		$Scene/airlockdoor.open_office_door()
		$heart.visible = true
		return


	await get_tree().create_timer(3.0).timeout
	
	phone_ringing = true
	$Scene/Phone/Phone/PhoneAudio.play(0)
	
func _physics_process(delta: float) -> void:
	var HEAD = $Character/Head
	var min_angle = 1000
	var min_dist = 1000
	for flesh in fleshies:
		if flesh != null:
			min_angle = min(abs($Character.get_aim_angle(flesh)), min_angle)
			min_dist = min(($Character.global_position - flesh.global_position).length(), min_dist)

	if scanning == false:
		$Static.volume_db = -80
		$Beep.volume_db = -80
	else:
		var volume = lerp(-45.0, -14.0, min_angle / 15.0)
		volume = clamp(volume, -45, -14)
		$Static.volume_db = volume
		
		var beep_volume = lerp(-14.0, -40.0, min_angle / 90.0)
		beep_volume = clamp(beep_volume, -40, -14)
		
		$Beep.volume_db = beep_volume
	
		beep_delay = lerp(0.25, 1.0, (min_angle - 10.0) / 30.0)
		beep_delay = clamp(beep_delay, 0.25, 1.5)
		
		$Beep.pitch_scale = lerp(1.2, 0.9, (min_angle - 10.0) / 20.0)
		$Beep.pitch_scale = clamp($Beep.pitch_scale, 0.9, 1.2)
		#print($Beep.pitch_scale)
		
		if $Beep/BeepTimer.time_left > beep_delay:
			$Beep/BeepTimer.start(beep_delay)
		

	
	_do_physics_query()

func _unhandled_input(event: InputEvent) -> void:
		
	if event.is_action_pressed("ui_cancel"):
		if !paused:
			pause()
		else:
			unpause()

func get_random_position_on_mesh() -> Vector3:
	# Choose a random point on the mesh by selecting random vertices
	var mesh = $FleshBall/TestFlesh.mesh

	if mesh == null:
		return global_position  # Default to the object's position if no mesh is available

	var surface_count = mesh.get_surface_count()
	if surface_count <=0:
		return Vector3(0,0,0)
	
	# Pick a random surface
	var surface_index = randi() % surface_count
	var surface_data = mesh.surface_get_arrays(surface_index)
	var vertices = surface_data[ArrayMesh.ARRAY_VERTEX]
	
	# Pick a random vertex on the surface
	var random_vertex = vertices[randi() % vertices.size()]
	var random_position = (random_vertex)
	
	# Optionally, adjust the random position slightly (e.g., offset from the surface)
	random_position.y -= 0.5  # Slightly adjust the Y to make the blood drip downward
	
	return random_position

func _process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		pause()

func _do_physics_query():
		
	
		$Character.RETICLE.set_reticle(1)

		var screen_center = Vector2(576.0, 324.0)
		
		var ray_origin = %Camera.project_ray_origin(screen_center)
		
		var ray_direction = %Camera.project_ray_normal(screen_center)

		var ray_end = ray_origin + (ray_direction * 2.0)
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)
		var dont_dialog = false
		
		cur_hover = result
		

		if result and result.collider.is_in_group("pickup"):
			$Character.RETICLE.set_reticle(0)
			if Input.is_action_just_pressed("click") && %Dialog.can_click:
				
				var pickup_name = result.collider.pickup_name
				if %Dialog.visible == false:
					if %Inventory.pick_up_item(pickup_name):
						result.collider.queue_free()
					
		if result and result.collider.is_in_group("fleshball"):
			if %Inventory.slots[%Inventory.cur_sel].item == "INJECTION":
				$Character.RETICLE.set_reticle(0)
				dont_dialog = true
				if Input.is_action_just_pressed("click") && %Inventory.can_swap:
					%Inventory.can_swap = false
					var hit_position = result.position
					var hit_normal = result.normal

					var hit_object = result.collider
					var hit_length = ($Character/Head.global_position - hit_position).length()
					var target_pos = ray_direction * 0.01
					
					add_flesh_ball(hit_position)
					
					$Character/Head/ItemContainer/Syringe.position = Vector3.ZERO
					var tween = create_tween()
					tween.tween_property($Character/Head/ItemContainer/Syringe, "position:z", -(hit_length - 0.3), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
					await tween.finished
					var aud = FreeAudioMono.new(INJECT, -10, 0)
					add_child(aud)
					$Character/Head/ItemContainer/Syringe/SyringeM/SyringeAnim.play("Inject")
					await $Character/Head/ItemContainer/Syringe/SyringeM/SyringeAnim.animation_finished
					tween = create_tween()
					tween.tween_property($Character/Head/ItemContainer/Syringe, "position:z", 0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
					await tween.finished

					
					#print("injec finished")
					%Inventory.drop_item()

					dont_dialog = true
					%Inventory.can_swap = true
					
			if %Inventory.slots[%Inventory.cur_sel].item == "SHOVEL":
				dont_dialog = true
				if !shovel_anim.is_playing():
					$Character.RETICLE.set_reticle(2)
					if Input.is_action_just_pressed("click"):
						shovel_anim.play("dig")
						%Inventory.can_swap = false
						await shovel.dig_signal
						%Inventory.can_swap = true
						var hit_position = result.position
						var hit_normal = result.normal
						var hit_object = result.collider
						#print("hit pos: ", hit_position + ray_direction * 0.75)
						$FleshBall.dig(hit_position, ray_direction)
						
		if result and result.collider.name == "Grinder":
			if %Inventory.slots[%Inventory.cur_sel].item == "FLESH":
				if Input.is_action_just_pressed("click"):
					%Inventory.drop_item()
					dont_dialog = true
					var n_injection = INJECTION.instantiate()
					$GrinderParts.start_p()
					await get_tree().create_timer(2.5).timeout
					$DingSound.play()
					_on_inventory_deposit_flesh()
					add_child(n_injection)
					n_injection.global_position = $InjectionSpawn.global_position
					
		if result and result.collider.name == "Phone" && phone_ringing:
			$Character.RETICLE.set_reticle(0)
			if Input.is_action_just_pressed("click"):
				phone_ringing = false
				$Scene/Phone/Phone/PhoneAudio.stop()
				%Dialog.play_dialog(%Dialog.get_phone_dia(week), 0)
				await %Dialog.dialog_ended
				#print("d ended")
				if week == 1:
					%ObjectiveLabel.visible = true
					%FleshMass.visible = true
					%FleshToFind.visible = true
				$Scene/airlockdoor.open_office_door()
				airlock_office_open = true
				pass
		
		if $FleshBall.end_seq && result && result.collider.name == "heart":
			if %Inventory.slots[%Inventory.cur_sel].item == "SHOVEL":
				$Character.RETICLE.set_reticle(0)
				if Input.is_action_just_pressed("click"):
					
					shovel_anim.play("dig")
					%Inventory.can_swap = false
					await shovel.dig_signal
					%Inventory.can_swap = true
					$FleshBall.dig(%heart.global_position, Vector3.ZERO)
					$heart.visible = false
					$heart.dead = true
					$heart/dead.play()
					$FleshBall.time_scale = 8.0
					await get_tree().create_timer(5.5).timeout

					$FleshBall.dead = true
					$FleshBall.time_scale = 0.0
					can_leave = true
					%ObjectiveLabel.obj_leave()
				
				
		
		if result and result.collider.has_node("DialogComponent") && !dont_dialog:
			
			$Character.RETICLE.set_reticle(0)
			if Input.is_action_just_pressed("click") && %Dialog.can_click:
				#print("click dialog")
				%Dialog.play_dialog(result.collider.get_node("DialogComponent").dialog, 0)
		
func _on_drip_timer_timeout() -> void:
	await get_tree().physics_frame
	var pos = $FleshBall/TestFlesh.to_global(get_random_position_on_mesh())
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pos, $Character.global_position, 1)
	
	var result = space_state.intersect_ray(query)
		
	var fl = BLOOD_PARTICLES.instantiate()
	add_child(fl)
		
	fl.global_position = pos

func change_vol(am):
	cur_vol -= am
	#print("cur vol: ", cur_vol, "total: ", total_vol)
	%FleshMass.text = "Product Mass: " + str((int(cur_vol / total_vol * 100))) + "%"
	if (int(cur_vol / total_vol * 100)) < 50:
		
		$LoadingTransition/Week.visible = false
		$LoadingTransition/AnimationPlayer.play("dissolve")
		await $LoadingTransition/AnimationPlayer.animation_finished
		$Character.global_position = Vector3(500,500,500)
		$Character.process_mode = Node.PROCESS_MODE_DISABLED
		%Dialog.play_dialog(["BOSS", "I warned you to keep the mass above 50%. Luckily we were able to keep the product alive, despite your negligence.",
		"However, you are still fired and will be billed an invoice for the damages you caused.", "Goodbye, and good luck with your future endeavors."], 0)
		await %Dialog.dialog_ended
		await get_tree().create_timer(0.5).timeout
		Transition.change_scene_to_menu()
		
func _on_area_3d_area_entered(area: Area3D) -> void:
	AudioServer.set_bus_effect_enabled(bus_index, 0, true)  # Enable
	#print("HHAA")
	pass # Replace with function body.


func _on_item_container_switched_to(item_name: Variant) -> void:
	if item_name == "SCANNER":
		scanning = true
	else:
		scanning = false
	pass # Replace with function body.



func _on_beep_timer_timeout() -> void:
	$Beep/BeepTimer.start(beep_delay)
	$Beep.play()
	pass # Replace with function body.


func _on_resume_button_pressed() -> void:
	unpause()
	pass # Replace with function body.


func _on_quit_to_menu_button_pressed() -> void:
	Transition.change_scene_to_menu()
	pass # Replace with function body.


func _on_inventory_deposit_flesh() -> void:
	%ObjectiveLabel.obj_inject()
	if first_time_process:
		first_time_process = false
		%Dialog.play_dialog(["SELF", "Now to inject the product with the growth hormones, then I can go home."], 0)
	pass # Replace with function body.


func _on_inventory_pickup_flesh() -> void:
	%ObjectiveLabel.obj_process()
	if first_time_pickup:
		first_time_pickup = false
		%Dialog.play_dialog(["SELF", "I need to go process this at the machine in the corner."], 0)
	pass # Replace with function body.


func _on_flesh_process_timer_timeout() -> void:
	pass # Replace with function body.

func add_flesh_ball(pos):
	
	
	
	#print("injecting at: ", pos)
	
	pos = pos / $FleshBall.scale.x
	var r_pos = Vector3(round(pos.x), round(pos.y), round(pos.z))
	
	#print("scaled/rounded: ", r_pos)
	
	r_pos = Vector3(r_pos.x, max(0, r_pos.y), r_pos.z)
	
	r_pos.x = clampf(r_pos.x, -6, 2)
	r_pos.y = clampf(r_pos.y, 0, 4)
	r_pos.z = clampf(r_pos.z, -6, 6)
	
	#print("min y 0: ", r_pos)
	var dir = Vector3.ZERO.direction_to(r_pos)
	var n_pos = round(Vector3.ZERO + (dir * 3))
	#print("on sphere rad: ", n_pos)
	if spheres.has(n_pos):
		
		spheres[n_pos] += 1
		spheres[n_pos] = clamp(spheres[n_pos],1, 4)
		#print("sphere grew: ", spheres[n_pos])
	else:
		spheres[n_pos] = 2
		
	flesh_remaining -= 1
	if flesh_remaining == 0:
		can_leave = true
		%ObjectiveLabel.obj_leave()
	else:
		%ObjectiveLabel.obj_find()
	%FleshToFind.text = "Injected: " + str(to_inject - flesh_remaining) + "/" + str(to_inject)
	return

func reset_flesh():
	$FleshBall.remesh()
	
	total_vol =  $FleshBall.get_volume()
	cur_vol = total_vol
	%ObjectiveLabel.obj_find()
	_set_high_quality_flesh(total_fleshies)
	to_inject = total_fleshies
	%FleshToFind.text = "Injected: " + str(to_inject - flesh_remaining) + "/" + str(to_inject)
	
	%FleshMass.text = "Product Mass: " + str((int(cur_vol / total_vol * 100))) + "%"





func _on_leave_area_body_entered(body: Node3D) -> void:
	#print(body)
	if !body.is_in_group("player"):
		return
	if !can_leave:
		return
	
	week += 1
	if week == 2:
		$table.global_position.y = -100
	if week == 5:
		Transition.change_scene_no_load(ENDINGSCENE)
		return

	flesh_remaining = -1
	can_leave = false
	

	total_fleshies += 1
	AudioServer.set_bus_mute(0, true)
	$LoadingTransition/Week.text = "Week: " + str(week)
	$LoadingTransition/AnimationPlayer.play("dissolve")
	await $LoadingTransition/AnimationPlayer.animation_finished
	$Character.global_transform = char_start
	$Character/Head.rotation = Vector3.ZERO
	
		
	if week == 4:
		$FleshBall.end_sequence()
		$heart.visible = true
		$heart.set_collision_layer_value(5, true)
	
	reset_flesh()
	$Scene/airlockdoor.reset_doors()
	var prev_vol = $Scene/airlockdoor/OfficeDoor.volume_db
	if week == 4:
		$Scene/airlockdoor/OfficeDoor.volume_db = -80
		$Scene/airlockdoor.open_office_door()
	
	await get_tree().create_timer(2.0).timeout
	if week == 4:
		AudioServer.set_bus_mute(0, false)
		$HomePhone.play()
		await $HomePhone.finished
		%Dialog.play_dialog(["BOSS", "We have a situation. Your coworkers... gone. No calls, no sign of them.", "Get in here. Now."], 0)
		await %Dialog.dialog_ended
		$Scene/airlockdoor/OfficeDoor.volume_db = prev_vol
	$LoadingTransition/AnimationPlayer.play_backwards("dissolve")
	AudioServer.set_bus_mute(0, false)
	await $LoadingTransition/AnimationPlayer.animation_finished
	
	await get_tree().create_timer(3.0).timeout
	if week <= 3:
		phone_ringing = true
		$Scene/Phone/Phone/PhoneAudio.play(0)
	pass # Replace with function body.


func _on_air_chamber_area_body_entered(body: Node3D) -> void:
	if $Scene/airlockdoor.office_door_open && !$Scene/airlockdoor.force_close:
		$Scene/airlockdoor.close_office_door()
		await get_tree().create_timer(1.5).timeout
		$Scene/airlockdoor/AirSound.play()
		await $Scene/airlockdoor/AirSound.finished
		await get_tree().create_timer(1.5).timeout
		$Scene/airlockdoor.open_chamber_door()
	if $Scene/airlockdoor.chamber_door_open && can_leave && !$Scene/airlockdoor.force_close:
		$Scene/airlockdoor.force_close = true
		
		$Scene/airlockdoor.close_chamber_door()
		await get_tree().create_timer(1.5).timeout
		$Scene/airlockdoor/AirSound.play()
		await $Scene/airlockdoor/AirSound.finished
		await get_tree().create_timer(1.5).timeout
		$Scene/airlockdoor.open_office_door()
	pass # Replace with function body.
