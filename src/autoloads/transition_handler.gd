extends Node

var gameScene: Node 
var mainMenuScene: Node
var currentScene: Node

func _ready() -> void:
	var root: Node = get_tree().get_root()
	var game: Resource = ResourceLoader.load("res://game/game.tscn")
	mainMenuScene = root.get_child(root.get_child_count() - 1)
	gameScene = game.instance()
	currentScene = mainMenuScene

func enterLobby() -> void:
	var root: Node = get_tree().get_root()
	root.remove_child(currentScene)
	root.add_child(gameScene)
	currentScene = gameScene
	get_tree().set_current_scene(currentScene)
	gameScene.load_map("res://game/maps/lobby/lobby.tscn")

func startGame() -> void:
	assert(false, "Not implemented yet")

func returnLobby() -> void:
	assert(false, "Not implemented yet")
