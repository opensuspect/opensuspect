extends Sprite

onready var skeleton: Node2D = $Viewport/Skeleton

var currentOutfit: Dictionary
var currentColors: Dictionary

# Apply the config to the skeleton
func applyConfig(outfit: Dictionary, colors: Dictionary):
	currentOutfit = outfit
	currentColors = colors
	## Applies appearance to its skeleton
	skeleton.applyAppearance(currentOutfit, currentColors)
