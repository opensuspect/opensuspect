extends Node2D

var spawnList: Array = [] # Storing spawn positions for current map
var spawnCounter: int = 0 # A counter to take care of where characters spawn
var actualMap: Node2D = null

var roles: Dictionary = {} # Stores the roles of all the players
# Stores the roles of the players based on what the current player sees
var visibleRoles: Dictionary = {}

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters
onready var roleScreenTimeout: Timer = $RoleScreenTimeout
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

signal teamsRolesAssigned

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

func addCharacter(networkId: int) -> void:
	## Create character resource
	var newCharacterResource: CharacterResource = Characters.createCharacter(networkId)
	newCharacterResource.setCharacterName(Connections.listConnections[networkId])
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

func _on_RoleScreenTimeout_timeout():
	TransitionHandler.gameStarted()

func setTeamsRolesOnCharacter(roles: Dictionary) -> void:
	var allCharacters: Dictionary = Characters.getCharacterResources()
	var teamName: String
	var roleName: String
	for characterID in allCharacters:
		print_debug("setting team and roles for  ", characterID)
		teamName = roles[characterID]["team"]
		roleName = roles[characterID]["role"]
		var textColor: Color = actualMap.teamsRolesResource.getRoleColor(teamName, roleName)
		allCharacters[characterID].setTeam(teamName)
		allCharacters[characterID].setRole(roleName)
		allCharacters[characterID].setNameColor(textColor)

# -- Client functions --
puppet func receiveTeamsRoles(newRoles: Dictionary) -> void:
	roles = newRoles
	var id: int = get_tree().get_network_unique_id()
	var myTeam: String = newRoles[id]["team"]
	var myRole: String = newRoles[id]["role"]
	visibleRoles = actualMap.teamsRolesResource.getVisibleTeamRole(newRoles, myTeam, myRole)
	setTeamsRolesOnCharacter(visibleRoles)
	emit_signal("teamsRolesAssigned", visibleRoles)
	roleScreenTimeout.start()

# -- Server functions --
func teamRoleAssignment() -> void:
	call_deferred("deferredTeamRoleAssignment")

func deferredTeamRoleAssignment() -> void:
	roles = actualMap.teamsRolesResource.assignTeamsRoles(Characters.getCharacterKeys())
	# TODO: RPC should not be done directly the game scene!
	rpc("receiveTeamsRoles", roles)
	if Connections.isClientServer():
		var id: int = get_tree().get_network_unique_id()
		var myTeam: String = roles[id]["team"]
		var myRole: String = roles[id]["role"]
		visibleRoles = actualMap.teamsRolesResource.getVisibleTeamRole(roles, myTeam, myRole)
	else:
		visibleRoles = roles
	setTeamsRolesOnCharacter(visibleRoles)
	emit_signal("teamsRolesAssigned", visibleRoles)
	roleScreenTimeout.start()
