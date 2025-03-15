@tool
extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		# Set environment to full-bright for the editor
		var full_bright_env = Environment.new()
		full_bright_env.background_mode = Environment.BG_COLOR
		full_bright_env.background_color = Color(0.8, 0.8, 0.8)  # White background (full-bright)
		environment = full_bright_env
	else:
		# Set environment to dark for the game
		var dark_env = Environment.new()
		dark_env.background_mode = Environment.BG_COLOR
		dark_env.background_color = Color(0, 0, 0)  # Dark background
		environment = dark_env
