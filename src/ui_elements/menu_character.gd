extends Control

onready var skeleton = $Viewport/Skeleton

# --Public Variables--

# Set the outline shader color
func setOutline(color: Color) -> void:
	$CharacterTexture.material.set_shader_param("line_color", color)

# Apply config from the appearance public variables to skeleton
func applyFromAppearance():
	setAppearance(Appearance.currentOutfit, Appearance.currentColors)

# Set config to skeleton from inputted variables
func setAppearance(outfit: Dictionary, colors: Dictionary):
	var outfitPaths: Dictionary = {}
	for partGroup in Appearance.currentOutfit: ## For each customizable group
		var selectedLook: String = outfit[partGroup]
		for part in Appearance.groupCustomization[partGroup]: ## For each custom sprite
			var filePath: String = Appearance.customSpritePaths[part][selectedLook]
			outfitPaths[part] = filePath
	skeleton.applyAppearance(outfitPaths, colors)

# --Private Variables--
func _ready():
	Appearance.connect("appearanceChanged", self, "applyFromAppearance") # Signal from appearance to set skeleton config
