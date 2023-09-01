extends Node

enum ConnectionTypes {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var connectionType: int = ConnectionTypes.LOCAL setget toss, getConnectionType
var myName: String = "" setget toss, getMyName
var serverName: String = "" setget toss, getServerName
const MAX_PLAYERS: int = 20
var listConnections: Dictionary = {} # Only lists playing connections, dedicated server is not here

# Variables used to sync data between clients and server on a regular basis
var broadcastDataQueue: Array = []
var sendToServerQueue: Array = []

var _dataSyncsPerSecond: int = 30
var _timeSinceDataSync: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "connectedOK")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "connectedFail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "disconnectedFromServer")

func _process(delta: float) -> void:
	if not TransitionHandler.isPlaying():
		return
	_timeSinceDataSync += delta
	## Only proceed if enough time passed
	if _timeSinceDataSync < 1.0 / _dataSyncsPerSecond:
		return
	## Reset position sync timer
	_timeSinceDataSync = 0.0
	## If server
	if Connections.isClientServer() or Connections.isDedicatedServer():
		## Collect all character positions
		var positions: Dictionary = Characters.gatherCharacterPositions()
		## Apply received character Data
		if len(sendToServerQueue) > 0:
			_receiveDataServer(1, sendToServerQueue)
			sendToServerQueue = []
		## Broadcast all character positions and data
		#if len(broadcastDataQueue) > 0:
			#print_debug(broadcastDataQueue)
		rpc("_receiveAllGameData", positions, broadcastDataQueue)
		broadcastDataQueue = []
	## If client
	elif Connections.isClient():
		if Characters.getMyCharacterResource() == null:
			return
		## Send own character position and queued data to server
		_sendQueuedDataToServer()
	else:
		assert(false, "Unreachable")

func toss(_newValue) -> void:
	pass

func getConnectionType() -> int:
	return connectionType

func getMyName() -> String:
	return myName

func getServerName() -> String:
	return serverName

func getMyId() -> int:
	return get_tree().get_network_unique_id()

func isServer() -> bool:
	return isDedicatedServer() or isClientServer()

func isLocal() -> bool:
	return isConnectionType(ConnectionTypes.LOCAL)

func isDedicatedServer() -> bool:
	return isConnectionType(ConnectionTypes.DEDICATED_SERVER)

func isClientServer() -> bool:
	return isConnectionType(ConnectionTypes.CLIENT_SERVER)

func isClient() -> bool:
	return isConnectionType(ConnectionTypes.CLIENT)

func isConnectionType(type: int) -> bool:
	return connectionType == type

# -------------- Client side code --------------

# warning-ignore:shadowed_variable
func joinGame(serverName: String, portNumber: int, playerName: String) -> void:
	## Initialize Godot networking
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
# warning-ignore:return_value_discarded
	peer.create_client(serverName, portNumber)
	get_tree().network_peer = peer
	var id: int = get_tree().get_network_peer().get_unique_id()
	## Save data in globals
	connectionType = ConnectionTypes.CLIENT
	myName = playerName
	#print_debug("Client_id is ", id)
	listConnections[id] = myName

func connectedOK() -> void:
	print_debug("Connected")
	## Send own data to server
	rpc_id(1, "receiveNewPlayerData", myName)
	## Load the game scene
	TransitionHandler.loadGameScene()

func connectedFail() -> void:
	print_debug("Connection failed")
	assert(false, "Not implemented yet")

func disconnectedFromServer() -> void:
	assert(false, "Not implemented yet")

puppet func receiveBulkPlayerData(connections: Dictionary) -> void:
	print_debug("Receiving data from server: ", connections)
	## Save all received data
	listConnections = connections
	#print_debug("Connected clients: ", listConnections)
	var gameScene: Node = TransitionHandler.gameScene
	## For all players
	for player in listConnections:
		## Create a character
		var characterRes: CharacterResource
		characterRes = Characters.createCharacter(player, listConnections[player])
		gameScene.addCharacter(characterRes)
	TransitionHandler.previouslyConnectedDataReceived()

puppet func setServerName(serverNewName: String) -> void:
	serverName = serverNewName
	#print_debug("Server name: ", serverName)

puppet func receivePlayerData(id: int, name: String) -> void:
	## If the data is not own data
	if id != get_tree().get_network_unique_id():
		## Save the data
		listConnections[id] = name
		var gameScene: Node = TransitionHandler.gameScene
		## Create a character
		var characterRes: CharacterResource
		characterRes = Characters.createCharacter(id, name)
		gameScene.addCharacter(characterRes)
	#print_debug("Connected clients: ", listConnections)

func queueDataToSend(key: String, value, recipient: int) -> void:
	sendToServerQueue.append({
		"key": key,
		"value": value,
		"recipient": recipient
	})

func _sendQueuedDataToServer() -> void:
	#print("sending my position to server")
	## Send own character position
	## and custom data to server
	var myPosition: Vector2 = Characters.getMyCharacterResource().getPosition()
	rpc_id(1, "_receiveGameDataFromClient", myPosition, sendToServerQueue)
	sendToServerQueue = []

# gameData = 	[	{"key": key1, "value": value1, "recipient": to1, "sender": from},
#					{"key": key2, "value": value2, "recipient": to2, "sender": from}]
puppet func _receiveAllGameData(positions: Dictionary, gameData: Array) -> void:
	if not TransitionHandler.isPlaying():
		return
	var myId: int = get_tree().get_network_unique_id()
	## Loop through all characters
	for characterId in positions:
		# if this position is for this client's character
		if characterId == myId:
			# don't update its position
			continue
		## Set the position for the character
		Characters.getCharacterResource(characterId).setPosition(positions[characterId])
	## Decompose character data
	#if len(gameData) > 0:
	#print_debug(gameData)
	var gameScene: Node = TransitionHandler.gameScene
	for data in gameData:
		## If recipient is me
		if data["recipient"] == myId or data["recipient"] == -1:
			## Apply data
			gameScene.setGameData(data)

# -------------- Server side code --------------

func createGame(portNumber: int, playerName: String) -> void:
	print_debug("port: ", portNumber)
	## Initialize Godot networking
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
# warning-ignore:return_value_discarded
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().network_peer = peer
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "connectedNewPlayer")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "disconnectedPlayer")
	connectionType = ConnectionTypes.CLIENT_SERVER
	## Save data in globals
	listConnections[1] = playerName
	myName = playerName
	serverName = playerName + "'s Server"
	## Load the game scene
	TransitionHandler.loadGameScene()

func createDedicated(portNumber: int, srvName: String) -> void:
	## Initialize Godot networking
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
# warning-ignore:return_value_discarded
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().network_peer = peer
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "connectedNewPlayer")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "disconnectedPlayer")
	## Save data in globals
	connectionType = ConnectionTypes.DEDICATED_SERVER
	serverName = srvName
	## Load the game scene
	TransitionHandler.loadGameScene()

# Once the newly joined player sent us their data, that's when we send them all the data
master func receiveNewPlayerData(newPlayerName: String) -> void:
	print_debug("new player joined ", newPlayerName)
	## Verify sender and save data
	var senderId: int = get_tree().get_rpc_sender_id()
	listConnections[senderId] = newPlayerName
	#print_debug(listConnections)
	rpc_id(senderId, "setServerName", serverName) ## Send server name
	## Send all player data to new player
	rpc_id(senderId, "receiveBulkPlayerData", listConnections)
	## Send new player data to all players
	rpc("receivePlayerData", senderId, newPlayerName)
	## Add a character to the map 
	var gameScene: Node = TransitionHandler.gameScene
	var characterRes: CharacterResource
	characterRes = Characters.createCharacter(senderId, newPlayerName)
	gameScene.addCharacter(characterRes)

# warning-ignore:unused_argument
func connectedNewPlayer(id: int) -> void:
	pass

# handling of disconnection for clients
puppet func disconnectPlayer(id: int) -> void:
	handleDisconnect(id) # literally just call this

# this function handles when a player disconnects, and is called on the network server
func disconnectedPlayer(id: int) -> void:
	#print_debug("connections server: removing character", id)
	rpc("disconnectPlayer", id)
	handleDisconnect(id)

## this function actually removes the player and stuff
func handleDisconnect(id:int) -> void:
# warning-ignore:return_value_discarded
	listConnections.erase(id)
	var characterResource: CharacterResource = Characters.getCharacterResource(id)
	characterResource.disconnected() ## call this function on the player to handle in-game reprocussions
	## remove character's node and resource
	Characters.removeCharacterResource(id)

func allowNewConnections(switch: bool) -> void:
	get_tree().refuse_new_network_connections = not switch

# receive a client's position
# master keyword means that this function will only be run on the server when RPCed
master func _receiveGameDataFromClient(newPos: Vector2, gameData: Array) -> void:
	var sender: int = get_tree().get_rpc_sender_id()
	## Set character position
	Characters.updateCharacterPosition(sender, newPos)
	## Handle additional received data
	_receiveDataServer(sender, gameData)

# gameData = 	[	{"key": key1, "value": value1, "recipient": to1},
#					{"key": key2, "value": value2, "recipient": to2}]
func _receiveDataServer(senderId: int, allGameData: Array) -> void:
	var gameScene: Node2D = TransitionHandler.gameScene
	## Loop through all recieved data entries
	for gameData in allGameData:
		## Validate and set game data
		var validatedData
		## Add the sender's ID to the data package
		gameData["sender"] = senderId
		## The game scene keeps the data element intact if valid, and changes it
		## to something valid if it isn't
		validatedData = gameScene.setGameData(gameData)
		## If the data was thrown away, do nothing
		if validatedData.empty():
			continue
		## If the data is not valid
		if validatedData != gameData["value"]:
			gameData["value"] = validatedData
			## If the data was not intended for broadcast
			if gameData["recipient"] != -1:
				## Add the data to the broadcast queue
				# will be sent out twice: once to the orig. sender and then the intended recipient
				broadcastDataQueue.append(gameData.duplicate())
			## Change the sender to the server
			gameData["sender"] = 1
			gameData["recipient"] = senderId
		## Add the data to the broadcast queue
		broadcastDataQueue.append(gameData)
	# Here the server could check and modify the data if necessary
	## Sets character data for the character requested

func queueDataToBroadcast(key: String, value, recipient: int, sender: int = 1) -> void:
	broadcastDataQueue.append({
		"key": key,
		"value": value,
		"recipient": recipient,
		"sender": sender
	})
