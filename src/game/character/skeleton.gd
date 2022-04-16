extends Node2D

# --Private Variables--

# Set the accepted file extensions to ".png"
var extensions: Array = [".png"]

# Directory of color maps. File names within should match shader names.
var colorMapDir: Dictionary = {
	"Color Maps": "res://game/character/assets/colormaps"
}

var _itemsInHand: Dictionary = {}
onready var handNode: Node2D = $Skeleton/Hip/RightShoulder/RArm1/RArm2/RHand

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
func applyAppearance(outfitPaths: Dictionary, colors: Dictionary) -> void:
	assert(not outfitPaths.empty(), "Missing outfit data")
	assert(not colors.empty(), "Missing colors data")
	## If received data valid
	if not outfitPaths.empty() and not colors.empty():
		_applyOutfit(outfitPaths) ## Apply Outfit
		_applyColors(colors) ## Apply colors

func putItemInHand(newItem: Node2D, itemId: int):
	if itemId in _itemsInHand:
		return
	newItem.position = Vector2(0, 0)
	_itemsInHand[itemId] = newItem
	handNode.add_child(newItem)

# --Private Functions--

# Applies the outfit to the skeleton
func _applyOutfit(outfitPaths: Dictionary) -> void:
	for part in outfitPaths: ## For each customizable group
		var nodePath = nodeStructure[part] ## Get the path to the node needing to be set
		var node = self.get_node(nodePath) ## Get the actual node object
		node.texture = load(outfitPaths[part]) ## Set the texture of the node

# Applies the colors to the shaders
func _applyColors(colors: Dictionary) -> void:
	for shader in colorShaders["Color Maps"]: ## Iterate over each shader
		var shaderName = colorShaders["Color Maps"][shader]["name"]
		var colorsForShader = Color( ## Sets the correct colors for the shader
		colors[shaderName]["Red"],
		colors[shaderName]["Green"],
		colors[shaderName]["Blue"])
		self.material.set_shader_param(shaderName, colorsForShader) ## Applies the colors to the given shader
