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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().connect("connected_to_server", self, "connectedOK")
	get_tree().connect("connection_failed", self, "connectedFail")
	get_tree().connect("server_disconnected", self, "disconnectedFromServer")

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

func joinGame(serverName: String, portNumber: int, playerName: String) -> void:
	## Initialize Godot networking
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
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
	## Enter the Lobby
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
		gameScene.addCharacter(player)

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
		gameScene.addCharacter(id)
	#print_debug("Connected clients: ", listConnections)

# -------------- Server side code --------------

func createGame(portNumber: int, playerName: String) -> void:
	print_debug("port: ", portNumber)
	## Initialize Godot networking
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "connectedNewPlayer")
	get_tree().connect("network_peer_disconnected", self, "disconnectedPlayer")
	connectionType = ConnectionTypes.CLIENT_SERVER
	## Save data in globals
	listConnections[1] = playerName
	serverName = playerName + "'s Server"
	## Load the game scene
	TransitionHandler.loadGameScene()

func createDedicated(portNumber: int, srvName: String) -> void:
	## Initialize Godot networking
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "connectedNewPlayer")
	get_tree().connect("network_peer_disconnected", self, "disconnectedPlayer")
	## Save data in globals
	connectionType = ConnectionTypes.DEDICATED_SERVER
	serverName = srvName
	## Enter the Lobby
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
	gameScene.addCharacter(senderId)

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
	listConnections.erase(id)
	var characterResource: CharacterResource = Characters.getCharacterResource(id)
	characterResource.disconnected() ## call this function on the player to handle in-game reprocussions
	## remove character's node and resource
	Characters.removeCharacterNode(id)
	Characters.removeCharacterResource(id)

func allowNewConnections(switch: bool) -> void:
	get_tree().refuse_new_network_connections = not switch
