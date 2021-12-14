extends Control

onready var create_game_menu: Control = $CreateGame
onready var join_menu: Control = $JoinGame
onready var dedicated_menu: Control = $Server
onready var main_menu: Control = $Menu

# Called when the node enters the scene tree for the first time.
func _ready():
	set_Visible_Menu("main_menu")
	
func _on_Back_pressed():
	set_Visible_Menu("main_menu")

func _on_GameCreateButton_pressed() -> void:
	set_Visible_Menu("create_game")

func _on_GameJoinButton_pressed() -> void:
	set_Visible_Menu("join_game")
	
func _on_ServerStartButton_pressed() -> void:
	set_Visible_Menu("create_server")

func _on_AppQuitButton_pressed() -> void:
	get_tree().quit()

func set_Visible_Menu(menu) -> void:
	hide_Menus()
	match menu:
		"main_menu": main_menu.visible = true
		"create_game": create_game_menu.visible = true
		"join_game": join_menu.visible = true
		"create_server": dedicated_menu.visible = true

func hide_Menus() -> void:
	main_menu.visible = false
	create_game_menu.visible = false
	join_menu.visible = false
	dedicated_menu.visible = false

func _on_Create_pressed() -> void:
	assert(false, "Game start not implemented yet")

func _on_Join_pressed() -> void:
	assert(false, "Game start not implemented yet")

func _on_Host_pressed() -> void:
	assert(false, "Game start not implemented yet")
