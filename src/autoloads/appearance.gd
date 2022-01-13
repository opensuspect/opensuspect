extends Node

signal configUpdated # Apply config for menu character

# --Public Variables--
var currentOutfit: Dictionary
var currentColors: Dictionary

var hasConfig: bool

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

# Set the accepted file extensions to ".png"
var extensions: Array = ["png"]

# --Private Variables--
# Directory of color maps. File names within should match shader names.
var colorMapDir: Dictionary = {
	"Color Maps": "res://game/character/assets/colormaps"
}

# Set the list of colormaps from the color map directory
onready var colorShaders = Resources.list(colorMapDir, extensions)

# Define which parts should be grouped under a parent part, and thus inherit the parent's clothing type
var groupClothing = {"Clothes": ["Left Arm", "Right Arm", "Pants", "Left Leg", "Right Leg"]}

# Color co-ordinates constant
const COLOR_XY = 500

# --Public Functions--

# Helper to apply the current outfit
func updateConfig() -> void:
	emit_signal("configUpdated")

# Set the outfit and color variables
func setConfig(outfit: Dictionary, colors: Dictionary) -> void:
	currentOutfit = outfit
	currentColors = colors
	updateConfig()

# Set one part of the outfit
func setOutfitPart(resource: String, namespace: String) -> void:
	var path = Resources.getPath(resource, namespace, directories, extensions)
	var outfit = currentOutfit
	outfit.erase(namespace)
	outfit[namespace] = {resource: path}
	var output = _groupOutfit(outfit)
	setConfig(output, currentColors)

# Set the color of a shader from a position
func setColorFromPos(shader: String, colorMap: String, position: Vector2) -> void:
	var colors = currentColors
	var color = getColorFromPos(colorMap, position)
	colors[shader] = _setColorInfo(color, position)
	setConfig(currentOutfit, colors)

# Get a color from a position on a color map
func getColorFromPos(path: String, position: Vector2) -> Color:
	var color = _colorFromMapXY(path, position)
	return(color)

# Randomize configuration
func randomizeConfig() -> void:
	setConfig(_randomOutfit(), _randomColors())

# --Private Functions--

# Create a random outfit for the character
func _randomOutfit() -> Dictionary:
	var outfit = Resources.getRandomOfEach(directories, extensions) # Get a fully random outfit
	return(_groupOutfit(outfit)) # Return the outfit

# Group arms and legs by the type of clothes and pants respectively
# This is done because each set of pants have corresponding leg assets for example
func _groupOutfit(outfit: Dictionary) -> Dictionary:
	for parentPart in groupClothing: # Iterate through clothing groups
		var clothesType = outfit[parentPart].keys().front() # Get the parent clothing type
		for childPart in groupClothing[parentPart]: # Iterate over the children parts
			# Get the child part's file path of the clothing type
			var path = Resources.getPath(clothesType, childPart, directories, extensions)
			if path.empty(): # Check if the child actually has that clothing type
				# If it does not have the clothing type, throw an error in debug
				assert(false, "Please add " + clothesType + " to " + childPart)
			else:
				# Otherwise set the child part to the clothing type matching the parent's
				outfit.erase(childPart)
				outfit[childPart] = {clothesType: path}
	return(outfit)

func _randomColors() -> Dictionary:
	var colors: Dictionary = {}
	for shader in colorShaders["Color Maps"]:
		var randX = randi() % COLOR_XY # Random X Position
		var randY = randi() % COLOR_XY # Random Y Position
		var position = Vector2(randX, randY)
		# Get the color from the position
		var randColor = _colorFromMapXY(colorShaders["Color Maps"][shader], position)
		colors[shader] = _setColorInfo(randColor, Vector2(randX, randY))
	return(colors)

# Creates a dictionary setting up the colors for the shader
func _setColorInfo(color: Color, position: Vector2) -> Dictionary:
	var colorInfo: Dictionary
	colorInfo["Red"] = color.r
	colorInfo["Green"] = color.g
	colorInfo["Blue"] = color.b
	colorInfo["Position"] = position
	return(colorInfo)

# Returns the color from the given color map, at the given relative co-ordinates
func _colorFromMapXY(colorMapPath: String, relPos: Vector2) -> Color:
	var colorMap = load(colorMapPath).get_data() # Loads the color map from the given path, and gets it's data
	var maxX = colorMap.get_width() # Get width of the color map
	var maxY = colorMap.get_height() # Get height of the color map
	var x = int(float(relPos.x) / COLOR_XY * maxX) # Sets the x position
	var y = int(float(relPos.y) / COLOR_XY * maxY) # Sets the y position
	colorMap.lock() # ???, but it breaks without it
	var color = colorMap.get_pixel(x, y) # Gets the color of the pixel at the co-ordinates
	colorMap.unlock() # ???, but it breaks without it
	return(color) # Returns the given color
