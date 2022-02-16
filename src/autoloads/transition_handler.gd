extends Node

enum States {
	MENU			# Not in game
	WAITING			# Between states
	LOBBY			# In the lobby where people can join
	ASSIGNMENT		# On the assignment screen
	MAP				# On a game map
}

var currentState: int = States.MENU setget toss, getCurrentState
var gameScene: Node2D setget toss, getGameScene

func isPlaying() -> bool:
	return currentState == States.LOBBY or currentState == States.MAP

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
	Scenes.switchBase("res://game/game.tscn", "res://game/hud.tscn")

func gameStarted() -> void:
	currentState = States.MAP
	Scenes.back()

puppetsync func startGame() -> void:
	## Load game map (laboratory)
	gameScene.loadMap("res://game/maps/chemlab/chemlab.tscn")
	## Overlay role assignment scene
	Scenes.overlay("res://game/role_assignment.tscn")
	## If server, assign roles
	if Connections.isServer():
		gameScene.teamRoleAssignment()

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
		currentState = States.ASSIGNMENT
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
