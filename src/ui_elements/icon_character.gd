extends Sprite

onready var skeleton = $Viewport/Skeleton

var currentOutfit: Dictionary
var currentColors: Dictionary

# Apply the config to the skeleton
func applyConfig(outfit: Dictionary, colors: Dictionary):
	currentOutfit = outfit
	currentColors = colors
	skeleton.applyAppearance(currentOutfit, currentColors)
