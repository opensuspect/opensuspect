extends Node2D

var spawnList: Array = [] # Storing spawn positions for current map
var meetingPosList: Array = [] # Storing the meeting positions to be teleporeted to
var spawnCounter: int = 0 # A counter to take care of where characters spawn
var actualMap: Node2D = null
var actualMapName: String = ""
var taskHandler: Node = null

var roles: Dictionary = {} # Stores the roles of all the players
# Stores the roles of the players based on what the current player sees
var visibleRoles: Dictionary = {}

var hudNode: Control = null
onready var mapNode: Node2D = $Map
onready var charactersNode: Node2D = $Characters
onready var corpsesNode: Node2D = $Corpses
onready var itemsNode: Node2D = $Items
onready var ghostsNode: Node2D = $Ghosts
onready var roleScreenTimeout: Timer = $RoleScreenTimeout
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

signal teamsRolesAssigned
signal abilityAssigned
signal clearAbilities
signal chatMessageReceived

func _ready() -> void:
	## Game scene loaded
	TransitionHandler.gameLoaded(self)

func _physics_process(delta: float) -> void:
	if not TransitionHandler.isPlaying():
		return
	var myCharacterRes: CharacterResource
	myCharacterRes = Characters.getMyCharacterResource()
	if myCharacterRes == null or not myCharacterRes.isAlive():
		return
	## Cast rays to every player from the main player
	var myCharacterNode: KinematicBody2D = myCharacterRes.getCharacterNode()
	var obstacleFinder: RayCast2D = myCharacterNode.obstacleFinder
	var myPosition: Vector2 = myCharacterRes.getGlobalPosition()
	var otherPosition: Vector2
	for otherCharacter in Characters.getCharacterResources().values():
		if otherCharacter == myCharacterRes:
			continue
		otherPosition = otherCharacter.getGlobalPosition()
		if (otherPosition - myPosition).length_squared() > 4e5:
			if otherCharacter.isAlive():
				otherCharacter.getCharacterNode().fadeInOut(false)
				continue
			otherCharacter.getCorpseNode().fadeInOut(false)
			continue
		var otherVisible: bool = false
		for offset in [
			Vector2(-10, 0), Vector2(10, 0), Vector2(0, -10), Vector2(0, 10)
		]:
			obstacleFinder.cast_to = otherPosition - myPosition + offset
			obstacleFinder.force_raycast_update()
			if obstacleFinder.get_collider() == null:
				otherVisible = true
				break
		if otherCharacter.isAlive():
			otherCharacter.getCharacterNode().fadeInOut(otherVisible)
		else:
			otherCharacter.getCorpseNode().fadeInOut(otherVisible)

func _process(delta: float) -> void:
	if not TransitionHandler.isPlaying():
		return
	var myCharacterRes: CharacterResource
	myCharacterRes = Characters.getMyCharacterResource()
	if myCharacterRes == null:
		return
	## Charater movement here
	if not myCharacterRes.canMove():
		return
	## Get movement vector based on keypress (not normalized)
	var movementVec: Vector2 = getMovementInput(false)
	var amountMoved: Vector2
	amountMoved = myCharacterRes.moveCommand(delta, movementVec)

# get the movement vector by looking at which keys are pressed
func getMovementInput(normalized: bool = true) -> Vector2:
	var vector: Vector2 = Vector2()
	# get the movement vector using the move_left, move_right, move_up, 
	# and move_down keys found in the input map
	vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if normalized:
		vector = vector.normalized()
	return vector

func setHudNode(newHudNode: Control) -> void:
	if hudNode != null:
		assert(false, "shouldn't set the hudNode again")
	hudNode = newHudNode
	if actualMap != null:
		actualMap.setHudNode(hudNode)

func setTaskHandler(newTaskHandler: Node) -> void:
	taskHandler = newTaskHandler

func loadMap(mapName: String) -> void:
	## Remove previous map if applicable
	for child in mapNode.get_children():
		child.queue_free()
	## Removove items from the map
	Items.clearItems()
	## Remove all corpses from the map
	for corpse in corpsesNode.get_children():
		corpse.queue_free()
	## Load map and place it on scene tree
	var mapPath: String = "res://game/maps/" + mapName + "/" + mapName + ".tscn"
	actualMap = ResourceLoader.load(mapPath).instance()
	actualMap.setHudNode(hudNode)
	actualMapName = mapName
	mapNode.add_child(actualMap)
	## Save spawn positions from the map
	var spawnPosNode: Node = actualMap.get_node("SpawnPositions")
	spawnList = []
	for posNode in spawnPosNode.get_children():
		spawnList.append(posNode.position)
	## Save meeting positions from the map
	var meetingPosNode: Node = actualMap.get_node("MeetingPosition")
	meetingPosList = []
	spawnCounter = 0
	for posNode in meetingPosNode.get_children():
		meetingPosList.append(posNode.position)
	## Reset all characters
	for characterResource in Characters.getCharacterResources().values():
		characterResource.reset()
		addCharacter(characterResource)
	## Spawn characters at spawn points
	spawnAllCharacters()
	## Request server for character data
	Characters.requestCharacterCustomizations()
	if hudNode != null and not Connections.isDedicatedServer():
		hudNode.refreshItemButtons()
		if len(meetingPosList) == 0:
			hudNode.showMeetingButton(false)
		else:
			hudNode.showMeetingButton(true)

func addCharacter(characterRes: CharacterResource):
	var newCharacter: KinematicBody2D = characterRes.getCharacterNode()
	charactersNode.add_child(newCharacter) ## Add node to scene
	var myId: int = Connections.getMyId()
	## If own character is added
	if characterRes.getNetworkId() == myId:
		newCharacter.connect("itemInteraction", self, "itemInteract")
		newCharacter.connect("taskInteraction", actualMap, "taskInteract")
	## Spawn the character
	spawnCharacter(characterRes)

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
	## Spawn character at next spawn position
	character.spawn(spawnList[spawnCounter])
	## Step spawn position counter
	spawnCounter += 1
	if spawnCounter >= len(spawnList):
		spawnCounter = 0

func removeCharacter(id: int) -> void:
	Characters.getCharacterResource(id).remove()
	## remove the resource and the node
	Characters.removeCharacterResource(id)

# Sets and validates game data received from other players or the server.
# Returns the same dictionary it received if the validation is successful.
# If a different dictionary is returned, the server will rebroadcast the
# properly set data as its own so the invalid data sender will receive the
# corrected data properly.
func setGameData(gameData: Dictionary) -> Dictionary:
	var id = gameData["sender"]
	var character: CharacterResource = null
	if id != 1 or not Connections.isDedicatedServer():
		character = Characters.getCharacterResource(id)
	## Apply character outfit and colors
	if gameData["key"] == "outfit":
		assert(character != null, "A dedicated server should not try to change its outfit")
		character.setOutfit(gameData["value"])
		return gameData["value"]
	if gameData["key"] == "colors":
		assert(character != null, "A dedicated server should not try to change its character colors")
		character.setColors(gameData["value"])
		return gameData["value"]
	if gameData["key"] == "meeting-chat":
		emit_signal("chatMessageReceived", gameData["value"], id)
		return gameData["value"]
	if gameData["key"] == "taskChanged":
		return actualMap.taskNodes.taskRemoteChanged(gameData["value"])
	return {}

func abilityActivate(parameters: Dictionary) -> void:
	# TODO: RPC should not be done directly the game scene!
	rpc_id(1, "abilityActServer", parameters)

func itemInteract(itemRes: ItemResource, action: String) -> void:
	hudNode.itemInteract(itemRes, action)

func itemPickUpAttempt(itemId: int) -> void:
	rpc_id(1, "itemPickUpServer", itemId)

func itemDropAttempt(itemId: int) -> void:
	rpc_id(1, "itemDropServer", itemId)

func itemActivateAttempt(itemId: int, abilityName: String, properties: Dictionary) -> void:
	rpc_id(1, "itemActivateServer", itemId, abilityName, properties)

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

func callMeeting() -> void:
	rpc_id(1, "callMeetingServer")

func voteCast(voteeId: int) -> void:
	rpc_id(1, "voteCastServer", voteeId)

# -- Client functions --
puppetsync func killCharacter(id: int) -> void:
	if id == Connections.getMyId():
		for characterRes in Characters.getCharacterResources().values():
			if characterRes.isAlive():
				characterRes.getCharacterNode().fadeInOut(true)
			else:
				characterRes.becomeGhost(characterRes.getPosition())
		hudNode.showMeetingButton(false)
	var seeGhosts: bool = (
		Connections.isDedicatedServer() or
		not Characters.getMyCharacterResource().isAlive()
	)
	Characters.getCharacterResource(id).die(seeGhosts)

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

puppetsync func itemPickUpClient(characterId: int, itemId: int) -> void:
	var characterRes: CharacterResource = Characters.getCharacterResource(characterId)
	var itemRes: ItemResource = Items.getItemResource(itemId)
	characterRes.pickUpItem(itemRes)
	if characterId == get_tree().get_network_unique_id():
		hudNode.hidePickUpButtons()
		hudNode.refreshItemButtons()

puppetsync func itemDropClient(characterId: int, itemId: int) -> void:
	var characterRes: CharacterResource = Characters.getCharacterResource(characterId)
	var itemRes: ItemResource = Items.getItemResource(itemId)
	characterRes.dropItem(itemRes)
	if characterId == get_tree().get_network_unique_id():
		hudNode.refreshItemButtons()
		hudNode.refreshPickUpButtons()

puppetsync func itemActivateClient(itemId: int, abilityName: String, properties: Dictionary) -> void:
	var itemRes: ItemResource = Items.getItemResource(itemId)
	itemRes.activate(abilityName, properties)
	if itemRes.getHolder().getNetworkId() == get_tree().get_network_unique_id():
		hudNode.refreshItemButtons()

puppetsync func teleportCharacters(teleportList: Dictionary) -> void:
	for characterIndex in teleportList:
		Characters.getCharacterResource(characterIndex).setPosition(teleportList[characterIndex])

puppetsync func startMeeting() -> void:
	if not Connections.isDedicatedServer():
		Characters.getMyCharacterResource().setMeetingMode()
	Scenes.overlay("res://game/ui_elements/meeting_ui.tscn", actualMap.voteResource)

puppetsync func endMeeting() -> void:
	if not Connections.isDedicatedServer():
		Characters.getMyCharacterResource().endMeetingMode()
	Scenes.back()

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
	# TODO: I'm not sure this is the appropriate place to reset the HUD for the abilities.
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

mastersync func itemPickUpServer(itemId: int) -> void:
	var playerId: int = get_tree().get_rpc_sender_id()
	var characterRes: CharacterResource = Characters.getCharacterResource(playerId)
	var itemRes: ItemResource = Items.getItemResource(itemId)
	if characterRes.canPickUpItem(itemRes):
		rpc("itemPickUpClient", playerId, itemId)

mastersync func itemDropServer(itemId: int) -> void:
	var playerId: int = get_tree().get_rpc_sender_id()
	var characterRes: CharacterResource = Characters.getCharacterResource(playerId)
	var itemRes: ItemResource = Items.getItemResource(itemId)
	if characterRes.canDropItem(itemRes):
		#TODO: think about whether we should enforce server-side coordinates for the items to be dropped.
		rpc("itemDropClient", playerId, itemId)

mastersync func itemActivateServer(itemId: int, abilityName: String, properties: Dictionary) -> void:
	var playerId: int = get_tree().get_rpc_sender_id()
	var itemRes: ItemResource = Items.getItemResource(itemId)
	if itemRes.canBeActivated(abilityName, properties):
		rpc("itemActivateClient", itemId, abilityName, properties)

func killCharacterServer(id: int) -> void:
	var characterRes: CharacterResource = Characters.getCharacterResource(id)
	if not characterRes.canBeKilled():
		return
	# TODO: is this something that the server needs to do one by one for every item
	# held by the killed character?
	for itemRes in characterRes.getItems():
		itemRes = itemRes as ItemResource
		if characterRes.canDropItem(itemRes):
			rpc("itemDropClient", id, itemRes.getId())
	rpc("killCharacter", id)

mastersync func callMeetingServer() -> void:
	var callerId: int = get_tree().get_rpc_sender_id()
	# TODO: do checks if the meeting can be called
	if not Characters.getCharacterResource(callerId).isAlive():
		return
	var meetingCounter = randi() % len(meetingPosList)
	var charResources: Dictionary = Characters.getCharacterResources()
	var teleport: Dictionary = {}
	var voteRes: VoteMechanicsTemplate = actualMap.voteResource
	voteRes.initialize()
	var characterRes: CharacterResource
	for characterIndex in charResources:
		characterRes = charResources[characterIndex]
		characterRes.setMeetingMode()
		if characterRes.isAlive():
			teleport[characterIndex] = meetingPosList[meetingCounter]
			meetingCounter += 1
			if meetingCounter >= len(meetingPosList):
				meetingCounter = 0
	rpc("teleportCharacters", teleport)
	rpc("startMeeting")

mastersync func voteCastServer(voteeId: int) -> void:
	var voterId: int = get_tree().get_rpc_sender_id()
	var voteRes: VoteMechanicsTemplate = actualMap.voteResource
	voteRes.receiveVote(voterId, voteeId)
	if voteRes.allVoted():
		var charResources: Dictionary = Characters.getCharacterResources()
		var characterRes: CharacterResource
		for characterIndex in charResources:
			characterRes = charResources[characterIndex]
			characterRes.endMeetingMode()
		voteRes.voteStop()
		rpc("endMeeting")

func voteTimeOut() -> void:
	var voteRes: VoteMechanicsTemplate = actualMap.voteResource
	if not voteRes.active:
		return
	var charResources: Dictionary = Characters.getCharacterResources()
	var characterRes: CharacterResource
	for characterIndex in charResources:
		characterRes = charResources[characterIndex]
		characterRes.endMeetingMode()
	voteRes.voteStop()
	rpc("endMeeting")
