#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/node.hpp>

#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/vector4.hpp>
#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <array>
#include <cmath>
#include <map>
#include <cstring>

namespace godot {

class GDExample : public Node {
	GDCLASS(GDExample, Node)

protected:
	static void _bind_methods();

public:
	GDExample();
	~GDExample();
	PackedVector3Array generate_marching_cubes(int chunk_size, Vector3 chunk_pos, PackedFloat32Array scalar_field, Vector3 scalar_size);
	void polygonize(int x, int y, int z, const PackedFloat32Array scalar_field, PackedVector3Array &vertices, Vector4 (&cube)[8], Vector3 (&vertlist)[12], int chunk_size);
	Vector3 linear_interp(Vector4 p1, Vector4 p2, float isolevel);
};

}

#endif