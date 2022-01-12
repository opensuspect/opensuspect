extends Sprite

onready var skeleton = $Viewport/Skeleton

var currentOutfit: Dictionary
var currentColors: Dictionary

func applyConfig(outfit: Dictionary, colors: Dictionary):
	currentOutfit = outfit
	currentColors = colors
	skeleton.applyConfig(currentOutfit, currentColors)
