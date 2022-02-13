extends Node2D

var spawnList: Array = [] # Storing spawn positions for current map
var spawnCounter: int = 0 # A counter to take care of where characters spawn
var actualMap: Node2D = null

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	TransitionHandler.gameLoaded(self)

func loadMap(mapPath: String) -> void:
	## Remove previous map if applicable
	for child in mapNode.get_children():
		child.queue_free()
	## Load map and place it on scene tree
	actualMap = ResourceLoader.load(mapPath).instance()
	mapNode.add_child(actualMap)
	## Save spawn positions from the map
	var spawnPosNode: Node = actualMap.get_node("SpawnPositions")
	spawnList = []
	for posNode in spawnPosNode.get_children():
		spawnList.append(posNode.position)
	## Spawn characters at spawn points
	spawnAllCharacters()
	## Request server for character data
	Characters.requestCharacterData()
	## Initiate role assignment
	call_deferred("teamRoleAssignment")

func teamRoleAssignment() -> void:
	var roles: Dictionary
	roles = actualMap.teamsRolesResource.assignTeamsRoles(Characters.getCharacterKeys())

func addCharacter(networkId: int) -> void:
	## Create character resource
	var newCharacterResource: CharacterResource = Characters.createCharacter(networkId)
	## Get character node reference
	var newCharacter: KinematicBody2D = newCharacterResource.getCharacterNode()
	## Spawn the character
	spawnCharacter(newCharacterResource)
	characterNode.add_child(newCharacter) ## Add node to scene
	var myId: int = get_tree().get_network_unique_id()
	if networkId == myId:
		## Apply appearance to character
		newCharacterResource.setAppearance(Appearance.currentOutfit, Appearance.currentColors)
		## Send my character data to server
		Characters.sendOwnCharacterData()

# These functions place the character on the map, but if it is a client, it will
# be overwritten by the position syncing. It is done only so that the characters
# are placed to a sane position no matter the network lag.
func spawnAllCharacters() -> void:
	## Reset spawn position counter
	spawnCounter = 0
	## Get all character resources
	var allChars: Dictionary = Characters.getCharacterResources()
	## Loop through all characters
	for character in allChars:
		spawnCharacter(allChars[character]) ## Set spawn position

func spawnCharacter(character: CharacterResource) -> void:
	## Set character position
	character.spawn(spawnList[spawnCounter])
	## Step spawn position counter
	spawnCounter += 1
	if spawnCounter > len(spawnList):
		spawnCounter = 0

func setCharacterData(id: int, characterData: Dictionary) -> void:
	var character: CharacterResource = Characters.getCharacterResource(id)
	if characterData.has("outfit") and characterData.has("colors"):
		character.setAppearance(characterData["outfit"], characterData["colors"])
