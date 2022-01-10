extends Node2D

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func loadMap(mapPath: String) -> void:
	## Load map and place it on scene tree
	var mapToLoad: Node = ResourceLoader.load(mapPath).instance()
	add_child_below_node(mapNode, mapToLoad)

func addCharacter(networkId: int) -> void:
	## Create character resource
	var newCharacterResource: CharacterResource = Characters.createCharacter(networkId)
	## Create character node
	var newCharacter: KinematicBody2D = newCharacterResource.getCharacterNode()
	## Randomize position
	var characterPosition: Vector2
	characterPosition.x = rng.randi_range(100, 500)
	characterPosition.y = rng.randi_range(100, 500)
	add_child_below_node(characterNode, newCharacter) ## Add node to scene
	newCharacterResource.setPosition(characterPosition) ## Apply position
