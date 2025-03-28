shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_frg_20;
uniform sampler2D tex_frg_2;

uniform float clearcoat : hint_range(0.0, 1.0, 0.01);
uniform float clearcoat_roughness : hint_range(0.0, 1.0, 0.01);
uniform sampler2D texture_clearcoat : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_texture;

void vertex() {

    float noise = sin(TIME * 3.0 + VERTEX.x * 5.0) * 0.05; // Simple sine-based perturbation
    VERTEX += NORMAL * noise; // Offset vertex to create subtle waves

	// Billboard Mode: Enabled
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);

	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);


// Input:3
	int n_out3p0 = INSTANCE_ID;


// VectorCompose:4
	float n_in4p1 = 1.00000;
	float n_in4p2 = 1.00000;
	vec3 n_out4p0 = vec3(float(n_out3p0), n_in4p1, n_in4p2);


// Output:0
	COLOR.rgb = n_out4p0;


}

vec3 fake_fluid_normals(vec2 uv) {
    float noise = sin(uv.x * 10.0 + TIME * 2.0) * cos(uv.y * 10.0 + TIME * 1.5);
    return normalize(vec3(noise, noise * 0.5, 1.0));
}

void fragment() {
// Input:4
	vec2 n_out4p0 = UV;


// UVFunc:21
	vec2 n_in21p1 = vec2(0.10000, 0.10000);
	vec2 n_in21p2 = vec2(0.00000, 0.00000);
	vec2 n_out21p0 = n_in21p2 * n_in21p1 + n_out4p0;


// Texture2D:20
	vec4 n_out20p0 = texture(tex_frg_20, n_out21p0);


// VectorOp:22
	vec3 n_in22p1 = vec3(1.20000, 1.20000, 1.20000);
	vec3 n_out22p0 = vec3(n_out20p0.xyz) * n_in22p1;


	vec2 n_out5p0;
// UVPolarCoord:5
	vec2 n_in5p1 = vec2(0.50000, 0.50000);
	float n_in5p2 = 0.80000;
	float n_in5p3 = 0.00000;
	{
		vec2 __dir = n_out4p0 - n_in5p1;
		float __radius = length(__dir) * 2.0;
		float __angle = atan(__dir.y, __dir.x) * 1.0 / (PI * 2.0);
		n_out5p0 = vec2(__radius * n_in5p2, __angle * n_in5p3);
	}


	vec3 n_out6p0;
// ColorFunc:6
	{
		vec3 c = vec3(n_out5p0, 0.0);
		float max1 = max(c.r, c.g);
		float max2 = max(max1, c.b);
		n_out6p0 = vec3(max2, max2, max2);
	}


// FloatFunc:7
	float n_out7p0 = 1.0 - n_out6p0.x;


// Input:15
	vec4 n_out15p0 = COLOR;


// VectorDecompose:16
	float n_out16p0 = vec3(n_out15p0.xyz).x;
	float n_out16p1 = vec3(n_out15p0.xyz).y;
	float n_out16p2 = vec3(n_out15p0.xyz).z;


// FloatOp:17
	float n_in17p1 = 0.10000;
	float n_out17p0 = n_out16p0 * n_in17p1;


// UVFunc:18
	vec2 n_in18p1 = vec2(1.00000, 1.00000);
	vec2 n_out18p0 = vec2(n_out17p0) * n_in18p1 + n_out4p0;


// Texture2D:2
	vec4 n_out2p0 = texture(tex_frg_2, n_out18p0);


// FloatOp:3
	float n_in3p1 = 3.00000;
	float n_out3p0 = pow(n_out2p0.x, n_in3p1);


// VectorOp:8
	vec3 n_out8p0 = vec3(n_out7p0) * vec3(n_out3p0);


// VectorOp:9
	vec3 n_out9p0 = n_out22p0 * n_out8p0;


// FloatConstant:14
	float n_out14p0 = 0.600000;


// FloatFunc:13
	float n_out13p0 = 1.0 - n_out8p0.x;


// Output:0
	ALBEDO = n_out9p0;
	ALPHA = n_out14p0;
	ALPHA_SCISSOR_THRESHOLD = n_out13p0;

	vec2 base_uv = UV;
	ROUGHNESS = 0.2;


    NORMAL = texture(normal_texture, UV).rgb;


}
