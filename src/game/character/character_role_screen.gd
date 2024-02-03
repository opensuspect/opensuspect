extends VBoxContainer

onready var resizer: Node2D = $Resizer
onready var skeleton: Node2D = $Resizer/PhotoPaper/Picture/Viewport/Skeleton
onready var nameLabel = $Name
onready var roleLabel = $Role

var currentOutfit: Dictionary
var outfitPaths: Dictionary = {}
var currentColors: Dictionary

var _characterName: String
var _roleString: String
var _size: int = 400

func changeSize(pixels: int) -> void:
	_size = pixels
	call_deferred("changeSizeDeferred")

func changeSizeDeferred():
	rect_min_size.x = _size
	rect_min_size.y = _size
	resizer.scale.x = _size/400.0
	resizer.scale.y = _size/400.0
# warning-ignore:integer_division
	resizer.position.x = _size/2
# warning-ignore:integer_division
	resizer.position.y = _size/2 + 40
	resizer.rotation_degrees = rand_range(-15, 15)

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

func setName(characterName: String, roleString: String) -> void:
	_characterName = characterName
	_roleString = roleString
	call_deferred("setNameDeferred")

func setNameDeferred() -> void:
	nameLabel.text = _characterName
	roleLabel.text = _roleString
