extends Node2D

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func loadMap(mapPath: String) -> void:
	## Remove previous map if applicable
	for child in mapNode.get_children():
		child.queue_free()
	## Load map and place it on scene tree
	var mapToLoad: Node = ResourceLoader.load(mapPath).instance()
	mapNode.add_child(mapToLoad)

func addCharacter(networkId: int) -> void:
	## Create character resource
	var newCharacterResource: CharacterResource = Characters.createCharacter(networkId)
	## Get character node reference
	var newCharacter: KinematicBody2D = newCharacterResource.getCharacterNode()
	## Randomize position
	var characterPosition: Vector2
	characterPosition.x = rng.randi_range(100, 500)
	characterPosition.y = rng.randi_range(100, 500)
	characterNode.add_child(newCharacter) ## Add node to scene
	newCharacterResource.setPosition(characterPosition) ## Apply position

func showStartButton(buttonShow: bool = true) -> void:
	$CanvasLayer/GameStart.visible = buttonShow
