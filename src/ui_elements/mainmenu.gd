extends Control

onready var create_game_menu: MarginContainer = $CreateGameMenu
onready var join_menu: MarginContainer = $JoinGameMenu
onready var dedicated_menu: MarginContainer = $DedicatedMenu
onready var main_menu: MarginContainer = $MainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_AppQuitButton_pressed():
	get_tree().quit()

func _on_ServerStartButton_pressed():
	dedicated_menu.visible = true
	main_menu.visible = false

func _on_GameJoinButton_pressed():
	join_menu.visible = true
	main_menu.visible = false

func _on_GameCreateButton_pressed():
	create_game_menu.visible = true
	main_menu.visible = false

func _on_BackButton_pressed():
	main_menu.visible = true
	dedicated_menu.visible = false
	join_menu.visible = false
	create_game_menu.visible = false

func _on_CreateGameStarter_pressed():
	assert(false, "Game start not implemented yet")

func _on_JoinGameStarter_pressed():
	assert(false, "Join Game not implemented yet")

func _on_DedicatedStarter_pressed():
	assert(false, "Dedicated server not implemented yet")
