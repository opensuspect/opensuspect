extends Control

# --Variables--
enum MenuType {MAIN, JOIN, CREATE, SERVER}

var menu: int

onready var main_menu: Control = $MainMenu
onready var join_menu: Control = $Join
onready var create_menu: Control = $Create
onready var server_menu: Control = $Server

onready var player = $MainMenu/CenterPlayer/Player/MenuPlayer/Skeleton

# --Interface--
func _ready() -> void:
	_randomIfUnset()
	player.applyConfig()
	menu = MenuType.MAIN
	setVisibleMenu(menu)

func _randomIfUnset() -> void:
	if not Appearance.hasConfig:
		Appearance.randomizeConfig()
		Appearance.hasConfig = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		joinEvent(menu)

func _on_Back_pressed() -> void:
	menu = MenuType.MAIN
	setVisibleMenu(menu)

func _on_GameJoinButton_pressed() -> void:
	menu = MenuType.JOIN
	setVisibleMenu(menu)

func _on_GameCreateButton_pressed() -> void:
	menu = MenuType.CREATE
	setVisibleMenu(menu)

func _on_ServerStartButton_pressed() -> void:
	menu = MenuType.SERVER
	setVisibleMenu(menu)

func _on_AppQuitButton_pressed() -> void:
	get_tree().quit()

func setVisibleMenu(menu) -> void:
	hideMenus()
	match menu:
		MenuType.MAIN: main_menu.visible = true
		MenuType.JOIN: join_menu.visible = true
		MenuType.CREATE: create_menu.visible = true
		MenuType.SERVER: server_menu.visible = true

func hideMenus() -> void:
	main_menu.visible = false
	join_menu.visible = false
	create_menu.visible = false
	server_menu.visible = false

# --Backend--
func joinGame() -> void:
	var nameField: LineEdit = $Join/Name
	var serverField: LineEdit = $Join/Address
	var port: int = 46690
	var host: String = serverField.text
	var name: String = nameField.text
	var cut_pos: int = host.find(":")
	if cut_pos != -1:
		port = int(host.right(cut_pos))
		host = host.left(cut_pos)
	print_debug("port: ", port, ", host: ", host)
	if host == "" or name == "":
		return
	Connections.joinGame(host, port, name)

func createGame() -> void:
	var nameField: LineEdit = $Create/Name
	var portField: LineEdit = $Create/Port
	var port: int = int(portField.text)
	var name: String = nameField.text
	if name == "":
		return
	Connections.createGame(port, name)

func createDedicated() -> void:
	var nameField: LineEdit = $Server/Name
	var portField: LineEdit = $Server/Port
	var port: int = int(portField.text)
	var name: String = nameField.text
	if name == "":
		return
	Connections.createDedicated(port, name)

func joinEvent(menu: int) -> void:
	match menu:
		MenuType.MAIN:
			menu = MenuType.JOIN
			setVisibleMenu(menu)
		MenuType.JOIN: joinGame()
		MenuType.CREATE: createGame()
		MenuType.SERVER: createDedicated()

func _on_Join_pressed() -> void:
	joinEvent(menu)
	
func _on_Create_pressed() -> void:
	joinEvent(menu)

func _on_Server_pressed() -> void:
	joinEvent(menu)

func _on_Player_pressed():
	get_tree().change_scene("res://ui_elements/appearance_editor.tscn")
