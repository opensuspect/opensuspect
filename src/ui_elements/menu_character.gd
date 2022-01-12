extends Control

onready var skeleton = $Viewport/Skeleton

# --Public Variables--
func setOutline(color: Color) -> void:
	$CharacterTexture.material.set_shader_param("line_color", color)

func applyAppearance():
	skeleton.applyConfig(Appearance.currentOutfit, Appearance.currentColors)

func setConfig(outfit: Dictionary, colors: Dictionary):
	skeleton.applyConfig(outfit, colors)

# --Private Variables--
func _ready():
	Appearance.connect("applyConfig", self, "applyAppearance")
