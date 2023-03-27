extends HBoxContainer

@onready var skeleton = $Character/Skeleton3D
@onready var nameTag = $Name
@onready var voteButton = $Button

var characterId: int = -1
var characterName: String
var outfit: Dictionary = {}
var colors: Dictionary = {}
var active: bool = true

signal voteCast

func _ready():
	nameTag.text = characterName
	voteButton.disabled = not active
	_setAppearance()

func setActive(canVote: bool) -> void:
	active = canVote
	if voteButton != null:
		voteButton.disabled = not active

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
	nameTag.add_theme_color_override("font_color", newColor)
