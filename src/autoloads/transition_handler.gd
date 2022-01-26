extends Node

enum States {
	MENU			# Not in game
	WAITING			# Between states
	LOBBY			# In the lobby where people can join
	MAP				# On a game map
}

var currentState: int = States.MENU setget toss, getCurrentState
var gameScene: Node2D setget toss, getGameScene

func toss(_newValue) -> void:
	pass

func showMainMenu() -> void:
	## Switch to main menu scene
	Scenes.switchBase("res://ui_elements/menu_base.tscn", "res://ui_elements/main_menu.tscn")
	currentState = States.MENU

func gameLoaded(newGameScene: Node2D) -> void:
	gameScene = newGameScene
	currentState = States.LOBBY
	enterLobby()
	if Connections.isClientServer():
		gameScene.addCharacter(1)

func loadGameScene() -> void:
	## Switch to the game scene
	currentState = States.WAITING
	Scenes.switchBase("res://game/game.tscn", "res://game/game.tscn")
	Scenes.overlay("res://game/hud.tscn", true)

puppetsync func startGame() -> void:
	## Load game map (laboratory)
	gameScene.loadMap("res://game/maps/chemlab/chemlab.tscn")

puppetsync func enterLobby() -> void:
	## Load lobby map
	gameScene.loadMap("res://game/maps/lobby/lobby.tscn")

func getCurrentState() -> int:
	return currentState

func getGameScene() -> Node2D:
	return gameScene

# -- Server functions --
func changeMap() -> void:
	## Are we in the lobby
	if currentState == States.LOBBY:
		rpc("startGame")				## Start the game
		currentState = States.MAP
		## No new connections allowed
		Connections.allowNewConnections(false)
	## Are we in the game
	elif currentState == States.MAP:
		rpc("enterLobby")				## Return to the lobby
		currentState = States.LOBBY
		## New connections allowed
		Connections.allowNewConnections(true)
	else:
		assert(false, "unreachable")
