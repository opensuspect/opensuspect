extends Node

enum connectionTypeList {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var connectionType: int = connectionTypeList.LOCAL setget toss, getConnectionType
var myName: String = "" setget toss, getMyName
const MAX_PLAYERS = 20
var listConnections = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connected_to_server", self, "connectedOK")
	get_tree().connect("connection_failed", self, "connectedFail")
	get_tree().connect("server_disconnected", self, "disconnectedFromServer")

func toss(_newValue) -> void:
	pass
	
func getConnectionType() -> int:
	return connectionType

func getMyName() -> String:
	return myName

# -------------- Client side code --------------

func joinGame(serverName: String, portNumber: int, playerName: String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverName, portNumber)
	get_tree().network_peer = peer
	var id: int = get_tree().get_network_peer().get_unique_id()
	myName = playerName
	print_debug("Client_id is ", id)
	listConnections[id] = myName

func connectedOK() -> void:
	rpc_id(1, "receiveNewPlayerData", myName)

func connectedFail() -> void:
	assert(false, "Not implemented yet")
	
func disconnectedFromServer() -> void:
	assert(false, "Not implemented yet")
	
puppet func receiveBulkPlayerData(connections: Dictionary) -> void:
	listConnections = connections
	print_debug(listConnections)

puppet func receivePlayerData(id: int, name: String) -> void:
	if id != get_tree().get_network_unique_id():
		listConnections[id] = name
	print_debug(listConnections)

# -------------- Server side code --------------

func createServer(portNumber: int, playerName: String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(portNumber, MAX_PLAYERS)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "connectedNewPlayer")
	get_tree().connect("network_peer_disconnected", self, "disconnectedPlayer")
	listConnections[1] = playerName

master func receiveNewPlayerData(newPlayerName: String) -> void:
	var senderId = get_tree().get_rpc_sender_id()
	listConnections[senderId] = newPlayerName
	print_debug(listConnections)
	rpc_id(senderId, "receiveBulkPlayerData", listConnections)
	rpc("receivePlayerData", senderId, newPlayerName)

func connectedNewPlayer(id: int) -> void:
	pass
	
func disconnectedPlayer(id: int) -> void:
	assert(false, "Not implemented yet")

