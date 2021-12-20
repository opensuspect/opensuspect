extends Node2D

onready var Resources = get_node("/root/Resources")

var part_list: Dictionary = {
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

var extensions: Array = [".png"]

func _ready():
	randomizePlayer()

func randomizePlayer():
	var configuration = randomConfig()
	_applyConfiguration(configuration)

func randomConfig():
	var configuration = Resources.getRandomOfEach(part_list, extensions)
	var clothing = ["Left Leg", "Right Leg", "Left Arm", "Right Arm", "Pants"]
	var clothesType = configuration["Clothes"].keys()[0]
	for namespace in clothing:
		var path = Resources.getPath(clothesType, namespace, part_list, extensions)
		if not path.empty():
			configuration[namespace][clothesType] = path
	return(configuration)

func _applyConfiguration(configuration):
	for resource in configuration.keys():
		for path in configuration[resource].keys():
			var nodePath = nodeStructure[resource]
			var resourcePath = configuration[resource][path]
			var node = self.get_node(nodePath)
			node.texture = load(resourcePath)
