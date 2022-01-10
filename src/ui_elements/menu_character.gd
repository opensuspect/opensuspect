extends Control

# --Public Variables--
func setOutline(color: Color) -> void:
	$CharacterTexture.material.set_shader_param("line_color", color)
