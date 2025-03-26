extends Node3D
class_name FleshBall

@export var chunk_size :int = 16
var chunk_size_ex = chunk_size + 1

var chunks_x = 4
var chunks_z = 4
var chunks_y = 4
var dead = false

const FLESH_PARTICLES = preload("res://FleshParticles.tscn")
const FLESH_PARTICLES2 = preload("res://FleshParticles2.tscn")
var sphere_pos := Vector3(chunks_x * chunk_size / 2,
					chunks_y * chunk_size / 2,
					chunks_z * chunk_size / 2)
var sphere_rad := 3

var scalars:PackedFloat32Array
const FLESH_HIT = preload("res://audio/flesh_hit.ogg")
var vertices:PackedVector3Array

@export var use_arr_mesh = false

@export var main:Node3D = null

var MarchingCubes:GDExample = GDExample.new()


const CHUNK = preload("res://chunk.tscn")

var chunks = {}

var custom_time = 0.0
var time_scale = 1.0
var time_scale_max

var time_tween:Tween

var z_range = (chunks_z) * chunk_size + 1
var x_range = (chunks_x) * chunk_size + 1
var y_range = (chunks_y) * chunk_size + 1

var scalar_size = Vector3(x_range, y_range, z_range)

var end_seq = false

func remesh():
	#global_position = Vector3(-chunk_size/2.0*scale.x, -chunk_size/2.0*scale.y, -chunk_size/2.0*scale.z)
	chunk_size_ex = chunk_size + 1
	if end_seq:
		scalars = end_scalar_field()
	else:
		scalars = gen_scalar_field()
	for z in range(0, chunks_z):
		for y in range(0, chunks_y):
			for x in range(0, chunks_x):
				old_gen(Vector3(x,y,z))

func end_scalar_field():
	var scalars:PackedFloat32Array = []
	
	
	
	for z in range(0, z_range):
		for y in range(0, y_range):
			for x in range(0, x_range):
				var val = 1
				
				if (x >= 21 && x <= 39) && (y >= 29 && y <= 35) && (z >= 23 && z <= 40):
					val = -1  # Inside the inner cube (this will overwrite the value inside the inner region)

				# The inner cube (smaller) boundaries
				if (x >= 29 && x <= 38) && (y >= 30 && y <= 34) && (z >= 30 && z <= 34):
					val = 1  # Inside the inner cube (overwrite to -1 here)
			
				if x == 32 && z == 32 && (y >= 20 && y <= 38):
					val = -1
				#val = max(val, inv_sdf_ellip(Vector3(x,y,z), Vector3(3,3,3)))
				#print(val)
				scalars.append(val)
	#print("done gen")
	return scalars
	
func gen_scalar_field():
	var scalars:PackedFloat32Array = []
	for z in range(0, z_range):
		for y in range(0, y_range):
			for x in range(0, x_range):
				scalars.append(sdf_sphere(Vector3(x,y,z)))
	return scalars




func sdf_sphere(pos:Vector3):
	var val = 1.0
	#print("sphere s: ", main.spheres)
	for sphere in main.spheres:
		#print("sphere: ", sphere)
		var sphere_pos = sphere + Vector3.ONE * chunks_x * chunk_size / 2
		val = min(val, sphere_pos.distance_to(pos) - main.spheres[sphere])
		pass
	
	return val

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if !dead:
		custom_time += (delta * time_scale)

	$TestFlesh.material_override.set_shader_parameter("custom_time", custom_time)
	#for chunk in chunks.values():
	#	chunk.get_mesh().material_override.set_shader_parameter("custom_time", custom_time)
		#print(chunk.get_mesh())
		#chunk.get_mesh().get_surface_override_material(0).set_shader_parameter("custom_time", custom_time)
	$FleshAmbiance.pitch_scale = 0.5 + 0.1 * time_scale
	
	return

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector3(-chunks_x * chunk_size / 2,
					-chunks_y * chunk_size / 2,
					-chunks_z * chunk_size / 2) * 1.5
	
	if !Engine.is_editor_hint():
		time_tween = create_tween()
	
	pass # Replace with function body.

func old_gen(chunk_pos):
	#print(chunk_pos)
	vertices = MarchingCubes.generate_marching_cubes(chunk_size, chunk_pos, scalars, scalar_size)

	
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vertex:Vector3 in vertices:
		st.add_vertex(vertex)
		
	st.generate_normals()
	chunks[chunk_pos] = st.commit()

	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for chunk_mesh in chunks.values():
		for i in range(chunk_mesh.get_surface_count()):
			st.append_from(chunk_mesh, i, Transform3D.IDENTITY)
	
	st.generate_normals()
	$TestFlesh.mesh = st.commit()
		
	#if !chunks.has(chunk_pos):
		#chunks[chunk_pos] = CHUNK.instantiate()
		#add_child(chunks[chunk_pos])
		#chunks[chunk_pos].reset_physics_interpolation()
		#chunks[chunk_pos].get_mesh().mesh = st.commit()
		#print("adding new chunk")
	#else:
		#chunks[chunk_pos].reset_physics_interpolation()
		#chunks[chunk_pos].get_mesh().mesh = st.commit()	
		#print("remaking chunk")
		
	
	$TestFleshBody/CollisionShape3D.shape = $TestFlesh.mesh.create_trimesh_shape()
	#var shape:ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	#shape.set_faces(vertices)
	#chunks[chunk_pos].get_col_shape().shape = shape
	


func dig_at_idx(idx, max, str):
	if idx >= 0:
		var before = scalars[idx]
		scalars[idx] = min(scalars[idx] + str, 2.0)
		if before < 0.5 && scalars[idx] >= 0.5:
			return 1
	return 0

func get_idx(x,y,z):	
	return x + y * y_range + z * z_range * z_range

func idx_to_xyz(idx: int) -> Vector3i:
	var x = idx % y_range
	var y = (idx / y_range) % y_range
	var z = idx / (y_range * y_range)
	return Vector3i(x, y, z)

func get_chunk_pos(vec):
	#print("chunk_vec ", floor(vec/chunk_size))
	return floor(vec/chunk_size)

func dig(position:Vector3, ray_direction:Vector3):
	var start_pos = position
	
	var chunk2 = chunk_size_ex * chunk_size_ex
	
	position = (position + ray_direction*0.5 - global_position) / scale.x
	var r_pos = Vector3(round(position.x), round(position.y), round(position.z))
	var max_size = chunk_size_ex * chunk_size_ex * chunk_size_ex
	#print("sphere pos in fleshball: ", sphere_pos)
	#print("hit in fleshball: ", r_pos)
	
	var amount = 0
	
	var chunks_to_reload = []
	chunks_to_reload.append(get_chunk_pos(Vector3(r_pos.x, r_pos.y, r_pos.z)))
	
	amount += dig_at_idx(get_idx(r_pos.x, r_pos.y, r_pos.z), max_size, 0.5)
	for x in range(-1,1):
		for y in range(-1,1):
			for z in range(-1,1):
				amount += dig_at_idx(get_idx(r_pos.x + x, r_pos.y + y, r_pos.z + z), max_size, 0.25)
	
	for x in range(-2,2):
		for y in range(-2,2):
			for z in range(-2,2):
				if !chunks_to_reload.has(get_chunk_pos(Vector3(r_pos.x + x, r_pos.y + y, r_pos.z + z))):
					chunks_to_reload.append(get_chunk_pos(Vector3(r_pos.x + x, r_pos.y + y, r_pos.z + z)))
			
	

	var fl = FLESH_PARTICLES.instantiate()
	get_parent().add_child(fl)
	fl.global_position = start_pos
		
	var fl2 = FLESH_PARTICLES2.instantiate()
	get_parent().add_child(fl2)
	fl2.global_position = start_pos
		
	await  get_tree().physics_frame
		
	var free_aud = FreeAudio3D.new(FLESH_HIT, -10)
	get_parent().add_child(free_aud)
	
	
	
	
	$DigEffectDur.start()
	time_scale = clamp(time_scale+(amount*1), 1.0, 8.0)
	time_scale_max = time_scale
	time_tween.kill()
		#get_surface_override_material(0).set_shader_parameter("pulse_speed", 1.5)
		#get_surface_override_material(0).set_shader_parameter("pulse_speed", 0.16)
	for chunk_vec in chunks_to_reload:
		old_gen(chunk_vec)
	#print("AMOUNT: ", amount)
	get_parent().change_vol(amount)

func _on_dig_effect_dur_timeout() -> void:
	if !time_tween.is_running():
		time_tween = create_tween()
		time_tween.tween_property(self, "time_scale", 1.0, 0.5 * time_scale_max)
		time_tween.set_ease(Tween.EASE_IN_OUT)
		time_tween.set_trans(Tween.TRANS_LINEAR)
	
	#get_surface_override_material(0).set_shader_parameter("pulse_speed", 0.55)
	#get_surface_override_material(0).set_shader_parameter("pulse_speed", 0.08)
	pass # Replace with function body.

func get_random_pos_in_surface():
	var list_pos_spots = []
	for i in range(scalars.size()):
		if scalars[i] < 0:
			list_pos_spots.append(i)
	var rand = randi_range(0, list_pos_spots.size() - 1)
	return idx_to_xyz(list_pos_spots[rand])

func get_volume():
	var vol = 0
	for i in range(scalars.size()):
		if scalars[i] < 0.5:
			vol += 1
	return vol

func end_sequence():
	end_seq = true
