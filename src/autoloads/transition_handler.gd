extends Node

var mapToLoad: Node

func enterLobby():
	print_debug("Server name: ", Connections.serverName)
	get_tree().change_scene("res://game/game.tscn")
	mapToLoad = load("res://game/maps/lobby/lobby.tscn").instance()

func startGame():
	assert(false, "Not implemented yet")

func returnLobby():
	assert(false, "Not implemented yet")
