extends HBoxContainer

onready var skeleton = $Character/Skeleton
onready var nameTag = $Name

var characterId: int = -1
var characterName: String
var outfit: Dictionary = {}
var colors: Dictionary = {}

signal voteCast

func _ready():
	nameTag.text = characterName
	_setAppearance()

func setId(newId: int) -> void:
	characterId = newId

func setName(newName: String) -> void:
	characterName = newName

func setAppearance(newOutfit: Dictionary, newColors: Dictionary) -> void:
	outfit = newOutfit
	colors = newColors

func _setAppearance() -> void:
	var outfitPaths: Dictionary = {}
	for partGroup in outfit: ## For each customizable group
		var selectedLook: String = outfit[partGroup]
		for part in Appearance.groupCustomization[partGroup]: ## For each custom sprite
			var filePath: String = Appearance.customSpritePaths[part][selectedLook]
			## Saves sprite file path
			outfitPaths[part] = filePath
	
	## Applies appearance to its skeleton
	skeleton.applyAppearance(outfitPaths, colors)

func _on_Button_pressed():
	emit_signal("voteCast", characterId)

func changeTextColor(newColor: Color) -> void:
	nameTag.add_color_override("font_color", newColor)
