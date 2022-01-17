extends Node

signal appearanceChanged # Apply config for menu character

# --Public Variables--
var currentOutfit: Dictionary
var currentColors: Dictionary

var hasConfig: bool
var customOutfit: bool

# Dictionary of asset folders
var directories: Dictionary = {
	"Body": "res://game/character/assets/textures/body",
	"Clothes": "res://game/character/assets/textures/clothes",
	"Mouth": "res://game/character/assets/textures/mouth",
	"Face Wear": "res://game/character/assets/textures/face_wear",
	"Facial Hair": "res://game/character/assets/textures/facial_hair",
	"Hat/Hair": "res://game/character/assets/textures/hat_hair",
	"Left Arm": "res://game/character/assets/textures/left_arm",
	"Left Leg": "res://game/character/assets/textures/left_leg",
	"Right Arm": "res://game/character/assets/textures/right_arm",
	"Right Leg": "res://game/character/assets/textures/right_leg",
	"Pants": "res://game/character/assets/textures/pants"
}

# Collects all the possible customizations
var customOptions: Dictionary = {}

# Collects all the file paths for possible customizations
var customSpritePaths: Dictionary = {}

# Set the accepted file extensions to ".png"
var extensions: Array = ["png"]

# --Private Variables--
# Directory of color maps. File names within should match shader names.
var colorMapDir: Dictionary = {
	"Color Maps": "res://game/character/assets/colormaps"
}

# Set the list of colormaps from the color map directory
onready var colorShaders = Resources.list(colorMapDir, extensions)

# Define which body parts work with which customizable parts
var groupCustomization = {
	"Clothes":
		["Clothes", "Left Arm", "Right Arm", "Pants", "Left Leg", "Right Leg"],
	"Body": ["Body"],
	"Mouth": ["Mouth"],
	"Face Wear": ["Face Wear"],
	"Facial Hair": ["Facial Hair"],
	"Hat/Hair": ["Hat/Hair"]}

# Color co-ordinates constant
const COLOR_XY = 500

func _ready():
	var assetList: Dictionary
	for group in groupCustomization:
		for partName in groupCustomization[group]:
			assetList = Resources.listDirectory(directories[partName], extensions)
			customSpritePaths[partName] = {}
			for asset in assetList:
				var assetName: String = assetList[asset]["name"]
				var assetPath: String = assetList[asset]["path"]
				customSpritePaths[partName][assetName] = assetPath
		customOptions[group] = []
		for asset in assetList:
			customOptions[group].append(assetList[asset]["name"])

# --Public Functions--

# Helper to apply the current outfit
func updateConfig() -> void:
	emit_signal("appearanceChanged") ## Emits appearanceChanged signal

# Set the outfit and color variables
func setConfig(outfitChange: Dictionary, colors: Dictionary) -> void:
	## Set current outfit and color
	for partGroup in outfitChange:
		currentOutfit[partGroup] = outfitChange[partGroup]
	currentColors = colors
	updateConfig() ## Update sample character

# Set one part of the outfit
func setOutfitPart(selectedItem: String, partName: String) -> void:
	var outfit: Dictionary = {}
	outfit[partName] = selectedItem ## Dictionary with changed element
	setConfig(outfit, currentColors) ## Sets custom outfit

# Set the color of a shader from a position
func setColorFromPos(shader: String, colorMap: String, position: Vector2) -> void:
	var colors = currentColors
	var color = getColorFromPos(colorMap, position) ## Get color from position on colormap
	colors[shader] = _setColorInfo(color, position) ## Sets color info
	setConfig(currentOutfit, colors) ## Sets custom outfit

# Get a color from a position on a color map
func getColorFromPos(path: String, position: Vector2) -> Color:
	var color = _colorFromMapXY(path, position)
	return(color)

# Randomize configuration
func randomizeConfig() -> void:
	customOutfit = false ## Set customOutfit to [FALSE]
	setConfig(_randomOutfit(), _randomColors()) ## Set random appearance

# --Private Functions--
func _randomPart(partName: String) -> String:
	var maxInt = customOptions[partName].size() # Get the size of the array
	var randInt = randi() % maxInt # Select a number between 0 and the size of maxInt
	return customOptions[partName][randInt]

# Create a random outfit for the character
func _randomOutfit() -> Dictionary:
	var outfit: Dictionary = {}
	for group in groupCustomization:
		outfit[group] = _randomPart(group)
	return outfit

func _randomColors() -> Dictionary:
	var colors: Dictionary = {}
	for shader in colorShaders["Color Maps"]:
		var shaderName: String = colorShaders["Color Maps"][shader]["name"]
		## Random position on colormap
		var randX = randi() % COLOR_XY # Random X Position
		var randY = randi() % COLOR_XY # Random Y Position
		var position = Vector2(randX, randY)
		## Get the color from position
		var randColor = _colorFromMapXY(colorShaders["Color Maps"][shader]["path"], position)
		colors[shaderName] = _setColorInfo(randColor, Vector2(randX, randY))
	return(colors)

# Creates a dictionary setting up the colors for the shader
func _setColorInfo(color: Color, position: Vector2) -> Dictionary:
	## Creates a dictionary of color info
	var colorInfo: Dictionary
	colorInfo["Red"] = color.r
	colorInfo["Green"] = color.g
	colorInfo["Blue"] = color.b
	colorInfo["XPos"] = position.x
	colorInfo["YPos"] = position.y
	return(colorInfo)

# Returns the color from the given color map, at the given relative co-ordinates
func _colorFromMapXY(colorMapPath: String, relPos: Vector2) -> Color:
	var colorMap = load(colorMapPath).get_data() ## Loads the color map from given path
	## Normalize coordinates
	var maxX = colorMap.get_width() # Get width of the color map
	var maxY = colorMap.get_height() # Get height of the color map
	var x = int(float(relPos.x) / COLOR_XY * maxX) # Sets the x position
	var y = int(float(relPos.y) / COLOR_XY * maxY) # Sets the y position
	## Reads color of pixel
	colorMap.lock() # locks the color map for access
	var color = colorMap.get_pixel(x, y) # Gets the color of the pixel at the co-ordinates
	colorMap.unlock() # unlocks the color map
	return(color) # Returns the given color
