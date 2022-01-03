extends Node

var gameScene: Node 
var mainMenuScene: Node
var currentScene: Node

func _ready() -> void:
	## Preload the game scene
	var root: Node = get_tree().get_root()
	var game: Resource = ResourceLoader.load("res://game/game.tscn")
	## Save current (main menu) scene
	mainMenuScene = root.get_child(root.get_child_count() - 1)
	currentScene = mainMenuScene
	## Instantiate and save th game scene
	gameScene = game.instance()

func enterLobby() -> void:
	## Switch to the game scene
	var root: Node = get_tree().get_root()
	root.remove_child(currentScene)
	root.add_child(gameScene)
	currentScene = gameScene
	get_tree().set_current_scene(currentScene)
	## Load lobby map
	gameScene.loadMap("res://game/maps/lobby/lobby.tscn")

func startGame() -> void:
	## Load game map (laboratory)
	gameScene.loadMap("res://game/maps/chemlab/chemlab.tscn")

func returnLobby() -> void:
	## Load lobby map
	gameScene.loadMap("res://game/maps/lobby/lobby.tscn")
