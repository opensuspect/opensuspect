extends Node

enum States {
	MENU,			# Not in game
	WAITING,		# Between states
	LOBBY,			# In the lobby where people can join
	ASSIGNMENT,		# On the assignment screen
	MAP				# On a game map
}

var _currentState: int = States.MENU
var currentState: int: get = getCurrentState, set = toss
var _gameScene: Node2D
var gameScene: Node2D: get = getGameScene, set = toss

func isPlaying() -> bool:
	return currentState == States.LOBBY or currentState == States.MAP

func toss(_newValue) -> void:
	assert(false)
	pass

func showMainMenu() -> void:
	## Switch to main menu scene
	Scenes.switchBase("res://ui_elements/menu_base.tscn", "res://ui_elements/main_menu.tscn")
	_currentState = States.MENU

func gameLoaded(newGameScene: Node2D) -> void:
	## Save reference to game scene
	_gameScene = newGameScene
	## Enter lobby
	enterLobby()
	## If client-server
	if Connections.isClientServer():
		## Add own character
		var characterRes: CharacterResource
		characterRes = Characters.createCharacter(1, Connections.myName)
		gameScene.addCharacter(characterRes)

func loadGameScene() -> void:
	## Switch to game scene and load HUD
	_currentState = States.WAITING
	Scenes.switchBase("res://game/game.tscn", "res://game/hud.tscn")

func gameStarted() -> void:
	print_debug("Game started")
	_currentState = States.MAP
	Scenes.back()

func previouslyConnectedDataReceived() -> void:
	print_debug("Received data for currently connected all players")
	_currentState = States.LOBBY

@rpc("call_local") func startGame() -> void:
	## Load game map (laboratory)
	gameScene.loadMap("chemlab")
	## Overlay role assignment scene
	Scenes.overlay("res://game/role_assignment.tscn")
	_currentState = States.ASSIGNMENT
	## If server, assign roles
	if Connections.isServer():
		gameScene.teamRoleAssignment(false)

@rpc("call_local") func enterLobby() -> void:
	## Load lobby map
	gameScene.loadMap("lobby")
	## If the connections have not been received yet we aren't actually in the
	## lobby state... unless we are the server.
	if len(Connections.listConnections) > 1 or Connections.isServer():
		## Switch to Lobby state
		_currentState = States.LOBBY
	## If server, assign roles
	if Connections.isServer():
		gameScene.teamRoleAssignment(true)

func getCurrentState() -> int:
	return _currentState

func getGameScene() -> Node2D:
	return _gameScene

# -- Server functions --
func changeMap() -> void:
	## Are we in the lobby
	if currentState == States.LOBBY:
		rpc("startGame")				## Start the game
		## No new connections allowed
		Connections.allowNewConnections(false)
	## Are we in the game
	elif currentState == States.MAP:
		rpc("enterLobby")				## Return to the lobby
		## New connections allowed
		Connections.allowNewConnections(true)
	else:
		assert(false) #,"unreachable")
