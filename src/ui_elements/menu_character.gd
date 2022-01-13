extends Control

onready var Appearance = get_node("/root/Appearance")

onready var skeleton = $Viewport/Skeleton

# --Public Variables--
func setOutline(color: Color) -> void:
	$CharacterTexture.material.set_shader_param("line_color", color)

func applyAppearance():
	skeleton.applyConfig(Appearance.currentOutfit, Appearance.currentColors)

# --Private Variables--
func _ready():
	Appearance.connect("applyConfig", self, "applyAppearance")
