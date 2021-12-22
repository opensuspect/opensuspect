extends Node2D

# --Private Variables--

onready var Resources = get_node("/root/Resources")

# Dictionary of asset folders
var directories: Dictionary = {
	"Body": "res://game/character/assets/textures/body",
	"Clothes": "res://game/character/assets/textures/clothes",
	"Face Wear": "res://game/character/assets/textures/face_wear",
	"Facial Hair": "res://game/character/assets/textures/facial_hair",
	"Hat/Hair": "res://game/character/assets/textures/hat_hair",
	"Mouth": "res://game/character/assets/textures/mouth",
	"Left Arm": "res://game/character/assets/textures/left_arm",
	"Left Leg": "res://game/character/assets/textures/left_leg",
	"Right Arm": "res://game/character/assets/textures/right_arm",
	"Right Leg": "res://game/character/assets/textures/right_leg",
	"Pants": "res://game/character/assets/textures/pants",
}

# Set the accepted file extensions to ".png"
var extensions: Array = [".png"]

# Directory of color maps. File names within should match shader names.
var colorMapDir: Dictionary = {
	"Color Maps": "res://game/character/assets/colormaps"
}

# Set the list of colormaps from the color map directory
onready var colorShaders = Resources.list(colorMapDir, extensions)

# Dictionary mapping each asset to a node path
var nodeStructure: Dictionary = {
	"Body": "Body",
	"Clothes": "Skeleton/Spine/Clothes",
	"Face Wear": "Skeleton/Spine/FaceWear",
	"Facial Hair": "Skeleton/Spine/FacialHair",
	"Hat/Hair": "Skeleton/Spine/HatHair",
	"Mouth": "Skeleton/Spine/Mouth",
	"Left Arm": "LeftArm",
	"Left Leg": "LeftLeg",
	"Right Arm": "RightArm",
	"Right Leg": "RightLeg",
	"Pants": "Pants",
}

# Define which parts should be grouped under a parent part, and thus inherit the parent's clothing type
var groupClothing = {"Clothes": ["Left Arm", "Right Arm"], "Pants": ["Left Leg", "Right Leg"]}

# Color co-ordinates constant
const COLOR_XY = 500

# --Public Functions--

# Helper function to apply both outfit and colors at once
func applyConfig(outfit: Dictionary, colors: Dictionary) -> void:
	applyOutfit(outfit)
	applyColors(colors)

# Applies the outfit to the skeleton
func applyOutfit(outfit: Dictionary) -> void:
	for part in outfit.keys(): # Iterate over each resource
		for path in outfit[part].keys(): # Iterate over each path
			var nodePath = nodeStructure[part] # Get the path to the node needing to be set
			var resourcePath = outfit[part][path] # Get the file path to the resource
			var node = self.get_node(nodePath) # Get the actual node object
			node.texture = load(resourcePath) # Set the texture of the node

# Applies the colors to the shaders
func applyColors(colors) -> void:
	for shader in colorShaders["Color Maps"].keys(): # Iterate over each shader
		var colorsForShader = Color( # Sets the correct colors for the shader
		colors[shader]["Red"],
		colors[shader]["Green"],
		colors[shader]["Blue"])
		self.material.set_shader_param(shader, colorsForShader) # Applies the colors to the given shader

# Generates a random outfit and colors, then applies the configuration
func randomizeConfig() -> void:
	var outfit: Dictionary = _randomOutfit()
	var colors: Dictionary = _randomColors()
	applyConfig(outfit, colors)

# --Private Functions--

func _ready() -> void:
	randomizeConfig()
	
# Create a random outfit for the character
func _randomOutfit() -> Dictionary:
	var outfit = Resources.getRandomOfEach(directories, extensions) # Get a fully random outfit
	# Group arms and legs by the type of clothes and pants respectively
	# This is done because each set of pants have corresponding leg assets for example
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
				outfit[childPart][clothesType] = path
	return(outfit) # Return the outfit

func _randomColors() -> Dictionary:
	var colors: Dictionary = {}
	for shader in colorShaders["Color Maps"]:
		var randX = randi() % COLOR_XY
		var randY = randi() % COLOR_XY
		var randColor = _colorFromMapXY(colorShaders["Color Maps"][shader], randX, randY)
		colors[shader] = {}
		colors[shader]["Red"] = randColor.r
		colors[shader]["Green"] = randColor.g
		colors[shader]["Blue"] = randColor.b
	return(colors)

# Returns the color from the given color map, at the given relative co-ordinates
func _colorFromMapXY(colorMapPath, xRel, yRel) -> Color:
	var colorMap = load(colorMapPath).get_data() # Loads the color map from the given path, and gets it's data
	var maxX = colorMap.get_width() # Get width of the color map
	var maxY = colorMap.get_height() # Get height of the color map
	var x = int(float(xRel) / COLOR_XY * maxX) # Sets the x position
	var y = int(float(yRel) / COLOR_XY * maxY) # Sets the y position
	colorMap.lock() # ???, but it breaks without it
	var color = colorMap.get_pixel(x, y) # Gets the color of the pixel at the co-ordinates
	colorMap.unlock() # ???, but it breaks without it
	return(color) # Returns the given color
