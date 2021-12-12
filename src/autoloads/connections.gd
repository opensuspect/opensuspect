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
	get_tree().connect("network_peer_connected", self, "connectedNewPlayer")
	get_tree().connect("network_peer_disconnected", self, "disconnectedPlayer")
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

func joinGame(serverIP: int, portNumber: int, playerName: String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, portNumber)

func connectedOK() -> void:
	
	assert(false, "Not implemented yet")

func connectedFail() -> void:
	assert(false, "Not implemented yet")
	
func disconnectedFromServer() -> void:
	assert(false, "Not implemented yet")

# -------------- Server side code --------------

func createServer(portNumber: int, playerName: String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(portNumber, MAX_PLAYERS)
	
func connectedNewPlayer() -> void:
	assert(false, "Not implemented yet")
	
func disconnectedPlayer() -> void:
	assert(false, "Not implemented yet")

