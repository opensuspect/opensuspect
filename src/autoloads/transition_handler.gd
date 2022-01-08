extends Node

var gameScene: Node 
var mainMenuScene: Node
var appearanceScene: Node
var currentScene: Node

func _ready() -> void:
	var root: Node = get_tree().get_root()
	var game: Resource = ResourceLoader.load("res://game/game.tscn")
	var appearance: Resource = ResourceLoader.load("res://ui_elements/appearance_editor.tscn")
	mainMenuScene = root.get_child(root.get_child_count() - 1)
	gameScene = game.instance()
	appearanceScene = appearance.instance()
	currentScene = mainMenuScene

func switchScene(nextScene: Node) -> void:
	var root: Node = get_tree().get_root()
	root.remove_child(currentScene)
	root.add_child(nextScene)
	currentScene = nextScene
	get_tree().set_current_scene(currentScene)

func enterLobby() -> void:
	switchScene(gameScene)
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

func startGame() -> void:
	assert(false, "Not implemented yet")

func returnLobby() -> void:
	assert(false, "Not implemented yet")
