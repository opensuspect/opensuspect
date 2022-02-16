extends Node

# this autoload manages character nodes and character resources

## HOW TO USE CHARACTER MANAGER
## Example: creating a character
## network id to use when creating a character (12345 is just an example id and
## most likely not what you will be using)
#	var networkId: int = 12345
#
## have the character manager create a character using that network id
#	Characters.createCharacter(networkId)
#	 > returns a CharacterResource corresponding to the character that was just
#		created


# --Public Variables--

# path to character scene
const CHARACTER_SCENE_PATH: String = "res://game/character/character.tscn"
var characterScene: PackedScene = preload(CHARACTER_SCENE_PATH)

# --Private Variables--

# _characterNodes and _characterResources are private variables because only this 
# 	script should be editing them

# stores character nodes keyed by network id
# {<network id>: <character node>}
var _characterNodes: Dictionary = {}

# stores character resources keyed by network id
# {<network id>: <character resource>}
var _characterResources: Dictionary = {}

# Stores data to be sent through the network during the next broadcast
var broadcastDataQueue: Array = []
var serverSendQueue: Array = []

var _positionSyncsPerSecond: int = 30
var _timeSincePositionSync: float = 0.0

# --Public Functions--

# create a new character for the given network id
# returns the character resource because I think it would be more useful than
# 	the character node - TheSecondReal0
func createCharacter(networkId: int) -> CharacterResource:
	## Create character node and resource
	var characterNode: Node = _createCharacterNode(networkId)
	var characterResource: CharacterResource = _createCharacterResource(networkId)
	
	## assign character nodes and resources to each other
	characterNode.setCharacterResource(characterResource)
	characterResource.setCharacterNode(characterNode)
	
	## register character node and resource
	_registerCharacterNode(networkId, characterNode)
	_registerCharacterResource(networkId, characterResource)
	
	## return character resource
	return characterResource

# get character node for the input network id
func getCharacterNode(id: int) -> Node:
	# if there is no character node corresponding to this network id
	if not id in _characterNodes:
		# throw an error
		printerr("Trying to get a nonexistant character node with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false, "Should be unreachable")
		# if running in release mode, return null
		return null
	return _characterNodes[id]

# get character resource for the input network id
func getCharacterResource(id: int) -> CharacterResource:
	# if there is no character node corresponding to this network id
	if not id in _characterResources:
		# throw an error
		printerr("Trying to get a nonexistant character resource with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false, "Should be unreachable")
		# if running in release mode, return null
		return null
	return _characterResources[id]

func getMyCharacterNode() -> Node:
	return _characterNodes[get_tree().get_network_unique_id()]

func getMyCharacterResource() -> CharacterResource:
	return _characterResources[get_tree().get_network_unique_id()]

func getCharacterNodes() -> Dictionary:
	return _characterNodes

func getCharacterResources() -> Dictionary:
	return _characterResources

func getCharacterKeys() -> Array:
	return _characterResources.keys()

func destroyCharacter() -> void:
	assert(false, "Not implemented yet")

# --Private Functions--

# create a character node, this function is used when creating a new character
func _createCharacterNode(networkId: int = -1) -> Node:
	## instance character scene
	var characterNode: Node = characterScene.instance()
	# set its network id
	characterNode.networkId = networkId
	# here is where we would set its player name, but that is not implemented yet
	return characterNode

# create a character resource, this function is used when creating a new character
func _createCharacterResource(networkId: int = -1) -> CharacterResource:
	## instance a new CharacterResource object
	var characterResource: CharacterResource = CharacterResource.new()
	# set its network id
	characterResource.networkId = networkId
	# here is where we would set its player name, but that is not implemented yet
	return characterResource

# add a character node to the characterNodes dictionary
func _registerCharacterNode(id: int, characterNode: Node) -> void:
	# if there is already a character node for this network id
	if id in _characterNodes:
		# throw an error
		printerr("Registering a character node that already exists, network id: ", id)
		assert(false, "Should be unreachable")
	## Register character node for id
	_characterNodes[id] = characterNode

# add a character resource to the characterResources dictionary
func _registerCharacterResource(id: int, characterResource: CharacterResource) -> void:
	# if there is already a character node for this network id
	if id in _characterResources:
		# throw an error
		printerr("Registering a character resource that already exists, network id: ", id)
		assert(false, "Should be unreachable")
	## Register character resource for id
	_characterResources[id] = characterResource

# ----------- PLAYER DATA SYNCING-----------

# --Universal Functions--

func _process(delta: float) -> void:
	if not TransitionHandler.isPlaying():
		return
	_timeSincePositionSync += delta
	## Only proceed if enough time passed
	if _timeSincePositionSync < 1.0 / _positionSyncsPerSecond:
		return
	## Reset position sync timer
	_timeSincePositionSync = 0.0
	## If server
	if Connections.isClientServer() or Connections.isDedicatedServer():
		## Broadcast all character positions
		var positions: Dictionary = {}
		for characterId in _characterResources:
			positions[characterId] = _characterResources[characterId].getPosition()
		##
		if len(serverSendQueue) > 0:
			receiveCharacterDataServer(1, serverSendQueue)
			serverSendQueue = []
		## Broadcast all character data
		#if len(broadcastDataQueue) > 0:
			#print_debug(broadcastDataQueue)
		rpc("_updateAllCharacterData", positions, broadcastDataQueue)
		broadcastDataQueue = []
	## If client
	elif Connections.isClient():
		if not get_tree().get_network_unique_id() in _characterResources:
			return
		## Send own character position to server
		_sendMyCharacterDataToServer()
	else:
		assert(false, "Unreachable")

## --Client functions

func requestCharacterData() -> void:
	rpc_id(1, "sendAllCharacterData")

# puppet keyword means that when this function is used in an rpc call
# 	it will only be run on client
puppet func _updateAllCharacterData(positions: Dictionary, characterData: Array) -> void:
	var myId: int = get_tree().get_network_unique_id()
	## Loop through all characters
	for characterId in positions:
		# if this position is for this client's character
		if characterId == myId:
			# don't update its position
			continue
		## Set the position for the character
		getCharacterResource(characterId).setPosition(positions[characterId])
	## Decompose character data
	#if len(characterData) > 0:
	#	print_debug(characterData)
	for data in characterData:
		if data["to"] == myId or data["to"] == -1:
			receiveCharacterDataClient(data["id"], data["data"])

func sendOwnCharacterData() -> void:
	var id: int = get_tree().get_network_unique_id()
	var characterRes: CharacterResource
	characterRes = Characters.getCharacterResource(id)
	var characterData: Dictionary = {}
	characterData["outfit"] = characterRes.getOutfit()
	characterData["colors"] = characterRes.getColors()
	serverSendQueue.append(characterData)

puppet func receiveCharacterDataClient(id: int, characterData: Dictionary) -> void:
	var gameScene: Node = TransitionHandler.gameScene
	gameScene.setCharacterData(id, characterData)

## --Server Functions--

master func sendAllCharacterData() -> void:
	var characterRes: Dictionary = {}
	characterRes = getCharacterResources()
	for player in characterRes:
		var characterData: Dictionary = {}
		var outfit: Dictionary = characterRes[player].getOutfit()
		var colors: Dictionary = characterRes[player].getColors()
		if len(outfit) > 0:
			characterData["outfit"] = outfit
		if len(colors) > 0:
			characterData["colors"] = colors
		if len(characterData) > 0:
			var senderId: int = get_tree().get_rpc_sender_id()
			var dataSend: Dictionary = {"to": senderId, "id": player, "data": characterData}
			broadcastDataQueue.append(dataSend)
	#print_debug(characterRes)
	#print_debug(broadcastDataQueue)

func receiveCharacterDataServer(senderId: int, characterData: Array) -> void:
	var gameScene: Node2D = TransitionHandler.gameScene
	## Decompose and compile received data
	if len(characterData) == 0:
		return
	var compiledData: Dictionary = {}
	for element in characterData:
		for key in element:
			compiledData[key] = element[key]
	# Here the server could check and modify the data if necessary
	## Sets character data for the character requested
	gameScene.setCharacterData(senderId, compiledData)
	## Broadcast new data
	var dataSend: Dictionary = {"to": -1, "id": senderId, "data": compiledData}
	broadcastDataQueue.append(dataSend)
	#print_debug(broadcastDataQueue)

# receive a client's position
# master keyword means that this function will only be run on the server when RPCed
master func _receiveCharacterDataFromClient(newPos: Vector2, characterData: Array) -> void:
	var sender: int = get_tree().get_rpc_sender_id()
	## Set character position
	_updateCharacterPosition(sender, newPos)
	receiveCharacterDataServer(sender, characterData)

# update a character's position
func _updateCharacterPosition(networkId: int, characterPos: Vector2) -> void:
	#print("updating position of ", networkId, " to ", characterPos)
	# if this position is for this client's character
	if networkId == get_tree().get_network_unique_id():
		# don't update its position
		return
	## Set the position for character
	getCharacterResource(networkId).setPosition(characterPos)

# --Client Functions

# send the position if this client's character to the server
func _sendMyCharacterDataToServer() -> void:
	#print("sending my position to server")
	## Send own character position to server
	var myPosition: Vector2 = getMyCharacterResource().getPosition()
	rpc_id(1, "_receiveCharacterDataFromClient", myPosition, serverSendQueue)
	serverSendQueue = []
