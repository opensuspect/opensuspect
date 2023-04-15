extends Node

enum ConnectionTypes {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var _connectionType: int = ConnectionTypes.LOCAL
var connectionType: int: get = getConnectionType, set = toss
var _myName: String = ""
var myName: String: get = getMyName, set = toss
var _serverName: String = ""
var serverName: String: get = getServerName, set = toss
const MAX_PLAYERS: int = 20
var listConnections: Dictionary = {} # Only lists playing connections, dedicated server is not here

# Variables used to sync data between clients and server on a regular basis
var broadcastDataQueue: Array = []
var sendToServerQueue: Array = []

var _dataSyncsPerSecond: int = 30
var _timeSinceDataSync: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().connect("connected_to_server", Callable(self, "connectedOK"))
	get_tree().connect("connection_failed", Callable(self, "connectedFail"))
	get_tree().connect("server_disconnected", Callable(self, "disconnectedFromServer"))

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
		assert(false) #,"Unreachable")

func toss(_newValue) -> void:
	assert(false)
	pass

func getConnectionType() -> int:
	return _connectionType

func getMyName() -> String:
	return _myName

func getServerName() -> String:
	return _serverName

func getMyId() -> int:
	return get_tree().get_multiplayer().get_unique_id()

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

func joinGame(serverName: String, portNumber: int, playerName: String) -> void:
	## Initialize Godot networking
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(serverName, portNumber)
	get_tree().network_peer = peer
	var id: int = get_tree().get_multiplayer_peer().get_unique_id()
	## Save data in globals
	_connectionType = ConnectionTypes.CLIENT
	_myName = playerName
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
	assert(false) #,"Not implemented yet")

func disconnectedFromServer() -> void:
	assert(false) #,"Not implemented yet")

@rpc func receiveBulkPlayerData(connections: Dictionary) -> void:
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

@rpc func setServerName(serverNewName: String) -> void:
	_serverName = serverNewName
	#print_debug("Server name: ", serverName)

@rpc func receivePlayerData(id: int, name: String) -> void:
	## If the data is not own data
	if id != getMyId():
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
@rpc func _receiveAllGameData(positions: Dictionary, gameData: Array) -> void:
	if not TransitionHandler.isPlaying():
		return
	var myId: int = getMyId()
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
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().get_multiplayer().multiplayer_peer = peer
	peer.peer_connected.connect(connectedNewPlayer)
	peer.peer_disconnected.connect(disconnectedPlayer)
	_connectionType = ConnectionTypes.CLIENT_SERVER
	## Save data in globals
	listConnections[1] = playerName
	_myName = playerName
	_serverName = playerName + "'s Server"
	## Load the game scene
	TransitionHandler.loadGameScene()

func createDedicated(portNumber: int, srvName: String) -> void:
	## Initialize Godot networking
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().network_peer = peer
	get_tree().connect("peer_connected", Callable(self, "connectedNewPlayer"))
	get_tree().connect("peer_disconnected", Callable(self, "disconnectedPlayer"))
	## Save data in globals
	_connectionType = ConnectionTypes.DEDICATED_SERVER
	_serverName = srvName
	## Load the game scene
	TransitionHandler.loadGameScene()

# Once the newly joined player sent us their data, that's when we send them all the data
# The master and mastersync rpc behavior is not officially supported anymore. Try using another keyword or making custom logic using get_multiplayer().get_remote_sender_id()
@rpc func receiveNewPlayerData(newPlayerName: String) -> void:
	print_debug("new player joined ", newPlayerName)
	## Verify sender and save data
	var senderId: int = get_tree().get_remote_sender_id()
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

func connectedNewPlayer(id: int) -> void:
	pass

# handling of disconnection for clients
@rpc func disconnectPlayer(id: int) -> void:
	handleDisconnect(id) # literally just call this

# this function handles when a player disconnects, and is called on the network server
func disconnectedPlayer(id: int) -> void:
	#print_debug("connections server: removing character", id)
	rpc("disconnectPlayer", id)
	handleDisconnect(id)

## this function actually removes the player and stuff
func handleDisconnect(id:int) -> void:
	listConnections.erase(id)
	var characterResource: CharacterResource = Characters.getCharacterResource(id)
	characterResource.disconnected() ## call this function on the player to handle in-game reprocussions
	## remove character's node and resource
	Characters.removeCharacterResource(id)

func allowNewConnections(switch: bool) -> void:
	get_tree().get_multiplayer(
		).get_multiplayer_peer(
		).refuse_new_connections = not switch

# receive a client's position
# master keyword means that this function will only be run on the server when RPCed
# The master and mastersync rpc behavior is not officially supported anymore. Try using another keyword or making custom logic using get_multiplayer().get_remote_sender_id()
@rpc func _receiveGameDataFromClient(newPos: Vector2, gameData: Array) -> void:
	var sender: int = get_tree().get_remote_sender_id()
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
		if validatedData.is_empty():
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
