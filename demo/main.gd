extends Node3D

@onready var camera: Freecam3D = $Freecam3D

		
func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("click"):
		var screen_center = get_viewport().size / 2.0
		
		var ray_origin = camera.project_ray_origin(screen_center)
		
		var ray_direction = camera.project_ray_normal(screen_center)

		var ray_end = ray_origin + (ray_direction * 10)
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)

		if result:
			var hit_position = result.position
			var hit_normal = result.normal
			var hit_object = result.collider
			print("hit pos: ", hit_position + ray_direction * 0.5)
			$MarchMesh.dig(hit_position + ray_direction * 0.5)
		
