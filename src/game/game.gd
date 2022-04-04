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
signal abilityAssigned
signal clearAbilities

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
	## Remove abilities from characters
	for characterResource in Characters.getCharacterResources().values():
		characterResource.resetCharacter()

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

func removeCharacter(networkId: int) -> void:
	#print_debug("game: removing character", networkId)
	var characterNode = Characters.getCharacterNode(networkId)
	characterNode.queue_free()
	## remove the resource and the node
	Characters.removeCharacterNode(networkId)
	Characters.removeCharacterResource(networkId)

func abilityActivate(parameters: Dictionary) -> void:
	# TODO: RPC should not be done directly the game scene!
	rpc_id(1, "abilityActServer", parameters)

func _on_RoleScreenTimeout_timeout():
	TransitionHandler.gameStarted()

func setTeamsRolesOnCharacter(roles: Dictionary) -> void:
	var allCharacters: Dictionary = Characters.getCharacterResources()
	var teamName: String
	var roleName: String
	for characterID in allCharacters:
		teamName = roles[characterID]["team"]
		roleName = roles[characterID]["role"]
		var textColor: Color = actualMap.teamsRolesResource.getRoleColor(teamName, roleName)
		allCharacters[characterID].setTeam(teamName)
		allCharacters[characterID].setRole(roleName)
		allCharacters[characterID].setNameColor(textColor)

# -- Client functions --
puppetsync func killCharacter(id: int) -> void:
	Characters.getCharacterResource(id).die()

puppet func receiveTeamsRoles(newRoles: Dictionary, isLobby: bool) -> void:
	var teamsRolesRes: TeamsRolesTemplate = actualMap.teamsRolesResource
	roles = newRoles
	var id: int = get_tree().get_network_unique_id()
	var myTeam: String = newRoles[id]["team"]
	var myRole: String = newRoles[id]["role"]
	visibleRoles = teamsRolesRes.getVisibleTeamRole(newRoles, myTeam, myRole)
	var rolesToShow: Array = teamsRolesRes.getTeamsRolesToShow(newRoles, myTeam, myRole)
	setTeamsRolesOnCharacter(visibleRoles)
	emit_signal("clearAbilities")
	if not isLobby:
		emit_signal("teamsRolesAssigned", visibleRoles, rolesToShow)
		roleScreenTimeout.start()

puppet func receiveAbility(newAbilityName: String) -> void:
	var teamsRolesRes: TeamsRolesTemplate = actualMap.teamsRolesResource
	var myCharacter: CharacterResource = Characters.getMyCharacterResource()
	var newAbility: Ability = teamsRolesRes.getAbilityByName(newAbilityName)
	if newAbility == null:
		return
	myCharacter.addAbility(newAbility)
	emit_signal("abilityAssigned", newAbilityName, newAbility)

puppet func executeAbility(parameters: Dictionary) -> void:
	var abilityName: String = parameters["ability"]
	var myCharacter: CharacterResource = Characters.getMyCharacterResource()
	if myCharacter.isAbility(abilityName):
		var abilityInstance: Ability = myCharacter.getAbility(abilityName)
		abilityInstance.execute(parameters)

# -- Server functions --
func teamRoleAssignment(isLobby: bool) -> void:
	call_deferred("deferredTeamRoleAssignment", isLobby)

func deferredTeamRoleAssignment(isLobby: bool) -> void:
	var teamsRolesRes: TeamsRolesTemplate = actualMap.teamsRolesResource
	## Assign teams and roles to all players
	roles = teamsRolesRes.assignTeamsRoles(Characters.getCharacterKeys())
	# TODO: RPC should not be done directly the game scene!
	rpc("receiveTeamsRoles", roles, isLobby)
	var abilities: Dictionary = {}
	abilities = teamsRolesRes.assignAbilities(Characters.getCharacterKeys(), roles)
	for character in abilities:
		var characterResource = Characters.getCharacterResource(character)
		for ability in abilities[character]:
			characterResource.addAbility(ability)
			#print_debug(character, ": ", ability.getName())
			# TODO: RPC should not be done directly in the game scene
			rpc_id(character, "receiveAbility", ability.getName())
	emit_signal("clearAbilities")
	var rolesToShow: Array = []
	if Connections.isClientServer():
		var id: int = get_tree().get_network_unique_id()
		var myTeam: String = roles[id]["team"]
		var myRole: String = roles[id]["role"]
		visibleRoles = teamsRolesRes.getVisibleTeamRole(roles, myTeam, myRole)
		rolesToShow = teamsRolesRes.getTeamsRolesToShow(visibleRoles, myTeam, myRole)
		for ability in Characters.getCharacterResource(id).getAbilities():
			var myAbilityName: String = ability.getName()
			emit_signal("abilityAssigned", myAbilityName, ability)
	else:
		visibleRoles = roles
	setTeamsRolesOnCharacter(visibleRoles)
	if not isLobby:
		emit_signal("teamsRolesAssigned", visibleRoles, rolesToShow)
		roleScreenTimeout.start()

remotesync func abilityActServer(parameters: Dictionary):
	var abilityPlayer: int = get_tree().get_rpc_sender_id()
	var abilityName: String = parameters["ability"]
	var abilityCharacter: CharacterResource = Characters.getCharacterResource(abilityPlayer)
	if abilityCharacter.isAbility(abilityName):
		var abilityInstance: Ability = abilityCharacter.getAbility(abilityName)
		if abilityInstance.canExecute(parameters):
			rpc_id(abilityPlayer, "executeAbility", parameters)
			abilityInstance.execute(parameters)

func killCharacterServer(id: int) -> void:
	rpc("killCharacter", id)
