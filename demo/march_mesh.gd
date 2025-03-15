@tool
extends MeshInstance3D

@export var chunk_size :int = 16
var chunk_size_ex = chunk_size + 1

@export var sphere_pos := Vector3(8,8,8)
@export var sphere_rad := 3.0

var scalars:PackedFloat32Array

var vertices:PackedVector3Array

@export var use_arr_mesh = false

var MarchingCubes:GDExample = GDExample.new()

@export_tool_button("Re-Mesh", "Callable") var remesh_action = remesh

func remesh():
	global_position = Vector3(-chunk_size/2.0, -chunk_size/2.0, -chunk_size/2.0)
	chunk_size_ex = chunk_size + 1
	scalars = gen_scalar_field()
	gen_mesh()

func gen_scalar_field():
	var scalars:PackedFloat32Array = []
	for z in range(chunk_size_ex):
		for y in range(chunk_size_ex):
			for x in range(chunk_size_ex):
				scalars.append(sdf_sphere(Vector3(x,y,z)))
	return scalars

func sdf_sphere(pos:Vector3):
	var dist:float = pos.distance_to(sphere_pos)
	if dist < sphere_rad:
		return 0.0
	else:
		return 1.0

func _process(delta: float) -> void:

	return

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector3(-chunk_size/2.0, -chunk_size/2.0, -chunk_size/2.0)
	scalars = gen_scalar_field()
	gen_mesh()
	
	pass # Replace with function body.

func old_gen():
	vertices = MarchingCubes.generate_marching_cubes(chunk_size, scalars)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vertex in vertices:
		st.add_vertex(vertex)
	st.generate_normals()
	mesh = st.commit()

	var shape:ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	shape.set_faces(vertices)
	$StaticBody3D/CollisionShape3D.shape = shape
	
func new_gen():
	mesh = MarchingCubes.generate_mesh(chunk_size, scalars)

func gen_mesh():
	if use_arr_mesh:
		new_gen()
		print("new gen")
	else:
		old_gen()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("gen")
		gen_mesh()

func dig(position:Vector3):
	position = (position - global_position) / scale.x
	var r_pos = Vector3(round(position.x), round(position.y), round(position.z))
	print("dig pos: ", r_pos)
	if r_pos >= Vector3.ZERO and r_pos <= Vector3.ONE * chunk_size:
		var idx = r_pos.x + r_pos.y * chunk_size_ex + r_pos.z * chunk_size_ex * chunk_size_ex
		scalars[idx] = 1.0
		gen_mesh()
