extends Node2D

# --Private Variables--

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
	"Clothes": "Clothes",
	"Face Wear": "FaceWear",
	"Facial Hair": "FacialHair",
	"Hat/Hair": "HatHair",
	"Mouth": "Mouth",
	"Left Arm": "LeftArm",
	"Left Leg": "LeftLeg",
	"Right Arm": "RightArm",
	"Right Leg": "RightLeg",
	"Pants": "Pants",
}

# --Public Functions--

# Apply config from appearance's variables
func applyAppearance(outfit: Dictionary, colors: Dictionary) -> void:
	_applyOutfit(outfit)
	_applyColors(colors)

# --Private Functions--

# Applies the outfit to the skeleton
func _applyOutfit(outfit: Dictionary) -> void:
	for part in outfit.keys(): # Iterate over each resource
		for path in outfit[part].keys(): # Iterate over each path
			var nodePath = nodeStructure[part] # Get the path to the node needing to be set
			var resourcePath = outfit[part][path] # Get the file path to the resource
			var node = self.get_node(nodePath) # Get the actual node object
			node.texture = load(resourcePath) # Set the texture of the node

# Applies the colors to the shaders
func _applyColors(colors: Dictionary) -> void:
	for shader in colorShaders["Color Maps"].keys(): # Iterate over each shader
		var colorsForShader = Color( # Sets the correct colors for the shader
		colors[shader]["Red"],
		colors[shader]["Green"],
		colors[shader]["Blue"])
		self.material.set_shader_param(shader, colorsForShader) # Applies the colors to the given shader
