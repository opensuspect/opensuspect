extends Node

enum States {
	MENU			# Not in game
	LOBBY			# In the lobby where people can join
	MAP				# On a game map
}

var gameScene: Node
var mainMenuScene: Node
var appearanceScene: Node
var currentScene: Node
var currentState: int = States.MENU setget toss, getCurrentState

func _ready() -> void:
	## Preload the game scene
	var root: Node = get_tree().get_root()
	var game: Resource = ResourceLoader.load("res://game/game.tscn")
	var appearance: Resource = ResourceLoader.load("res://ui_elements/appearance_editor.tscn")
	## Save current (main menu) scene
	mainMenuScene = root.get_child(root.get_child_count() - 1)
	## Instantiate and save th game scene
	gameScene = game.instance()
	## Instance the appearance editor scene
	appearanceScene = appearance.instance()
	## Current scene is the main menu
	currentScene = mainMenuScene

func switchScene(nextScene: Node) -> void:
	## Removes current scene from scene tree
	var root: Node = get_tree().get_root()
	root.remove_child(currentScene)
	## Sets the next scene as the current scene
	root.add_child(nextScene)
	currentScene = nextScene
	get_tree().set_current_scene(currentScene)

func toss(_newValue) -> void:
	pass

func enterLobby() -> void:
	## Switch to the game scene
	switchScene(gameScene)
	currentState = States.LOBBY
	## Load lobby map
	gameScene.loadMap("res://game/maps/lobby/lobby.tscn")

func showMainMenu() -> void:
	## Refresh the look of the character in the main menu
	mainMenuScene.player.applyConfig()
	## Switch to main menu scene
	switchScene(mainMenuScene)

func showAppearanceEd() -> void:
	## Checks what the the current scene is
	match currentScene:
		mainMenuScene:
			## Sets the main menu scene as the parent scene
			appearanceScene.parentScene = appearanceScene.CallerScene.MAINMENU
		_:
			assert(false, "Unreachable")
	## Switches scene
	switchScene(appearanceScene)

puppetsync func startGame() -> void:
	## Load game map (laboratory)
	gameScene.loadMap("res://game/maps/chemlab/chemlab.tscn")

puppetsync func returnLobby() -> void:
	## Load lobby map
	gameScene.loadMap("res://game/maps/lobby/lobby.tscn")

func getCurrentState() -> int:
	return currentState

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
		rpc("returnLobby")				## Return to the lobby
		currentState = States.LOBBY
		## New connections allowed
		Connections.allowNewConnections(true)
	else:
		assert(false, "unreachable")
