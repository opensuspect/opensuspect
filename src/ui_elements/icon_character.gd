extends Sprite2D

@onready var skeleton: Node2D = $SubViewport/Skeleton3D

var currentOutfit: Dictionary
var currentColors: Dictionary

# Apply the config to the skeleton
func applyConfig(outfit: Dictionary, colors: Dictionary):
	currentOutfit = outfit
	currentColors = colors
	var outfitPaths: Dictionary = {}
	for partGroup in currentOutfit: ## For each customizable group
		var selectedLook: String = currentOutfit[partGroup]
		for part in Appearance.groupCustomization[partGroup]: ## For each custom sprite
			var filePath: String = Appearance.customSpritePaths[part][selectedLook]
			outfitPaths[part] = filePath
	
	## Applies appearance to its skeleton
	skeleton.applyAppearance(outfitPaths, currentColors)
