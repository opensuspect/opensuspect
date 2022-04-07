extends Control

onready var skeleton: Node2D = $Skeleton
onready var nameLabel = $Name

var currentOutfit: Dictionary
var outfitPaths: Dictionary = {}
var currentColors: Dictionary

var _characterName: String
var _fontColor: Color

# Apply the config to the skeleton
func applyConfig(outfit: Dictionary, colors: Dictionary) -> void:
	currentOutfit = outfit
	currentColors = colors
	for partGroup in currentOutfit: ## For each customizable group
		var selectedLook: String = currentOutfit[partGroup]
		for part in Appearance.groupCustomization[partGroup]: ## For each custom sprite
			var filePath: String = Appearance.customSpritePaths[part][selectedLook]
			outfitPaths[part] = filePath
	call_deferred("applyConfigDeferred")

func applyConfigDeferred() -> void:
	## Applies appearance to its skeleton
	skeleton.applyAppearance(outfitPaths, currentColors)

func setName(characterName: String, fontColor: Color) -> void:
	_characterName = characterName
	_fontColor = fontColor
	call_deferred("setNameDeferred")

func setNameDeferred() -> void:
	nameLabel.text = _characterName
	nameLabel.add_color_override("font_color", _fontColor)
