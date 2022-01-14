extends Control

onready var skeleton = $Viewport/Skeleton

# --Public Variables--

# Set the outline shader color
func setOutline(color: Color) -> void:
	$CharacterTexture.material.set_shader_param("line_color", color)

# Apply config from the appearance public variables to skeleton
func applyFromAppearance():
	skeleton.applyAppearance(Appearance.currentOutfit, Appearance.currentColors)

# Set config to skeleton from inputted variables
func setAppearance(outfit: Dictionary, colors: Dictionary):
	skeleton.applyAppearance(outfit, colors)

# --Private Variables--
func _ready():
	Appearance.connect("appearanceChanged", self, "applyFromAppearance") # Signal from appearance to set skeleton config
	Appearance.randomizeIfUnset()
