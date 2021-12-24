extends Control

# --Variables--
enum MenuType {MAIN, JOIN, CREATE, SERVER}

var menu: int

onready var mainMenu: Control = $MainMenu
onready var joinMenu: Control = $Join
onready var createMenu: Control = $Create
onready var serverMenu: Control = $Server

# --Interface--
func _ready() -> void:
	menu = MenuType.MAIN
	setVisibleMenu(menu)

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

func setVisibleMenu(menuType: int) -> void:
	hideMenus()
	match menuType:
		MenuType.MAIN: mainMenu.visible = true
		MenuType.JOIN: joinMenu.visible = true
		MenuType.CREATE: createMenu.visible = true
		MenuType.SERVER: serverMenu.visible = true

func hideMenus() -> void:
	mainMenu.visible = false
	joinMenu.visible = false
	createMenu.visible = false
	serverMenu.visible = false

# --Backend--
func joinGame() -> void:
	## Get data from UI
	var nameField: LineEdit = $Join/Name
	var serverField: LineEdit = $Join/Address
	var port: int = 46690
	var host: String = serverField.text
	var playerName: String = nameField.text
	var cut_pos: int = host.find(":")
	## If port is given
	if cut_pos != -1:
		## Custom port is used
		port = int(host.right(cut_pos))
		host = host.left(cut_pos)
	print_debug("port: ", port, ", host: ", host)
	## Empty host or playername rejected
	if host == "" or playerName == "":
		return
	## Join a game
	Connections.joinGame(host, port, playerName)

func createGame() -> void:
	## Get data from UI
	var nameField: LineEdit = $Create/Name
	var portField: LineEdit = $Create/Port
	var port: int = int(portField.text)
	var name: String = nameField.text
	## Empty playername rejected
	if name == "":
		return
	## Create a game
	Connections.createGame(port, name)

func createDedicated() -> void:
	## Get data from UI
	var nameField: LineEdit = $Server/Name
	var portField: LineEdit = $Server/Port
	var port: int = int(portField.text)
	var name: String = nameField.text
	## Empty servername rejected
	if name == "":
		return
	## Create a dedicated server
	Connections.createDedicated(port, name)

func joinEvent(menu: int) -> void:
	## Checks menu
	match menu:
		MenuType.MAIN:
			menu = MenuType.JOIN
			setVisibleMenu(menu)
		MenuType.JOIN: joinGame() ## Join game
		MenuType.CREATE: createGame() ## Create a game
		MenuType.SERVER: createDedicated() ## Dedicated server

func _on_Join_pressed() -> void:
	joinEvent(menu)
	
func _on_Create_pressed() -> void:
	joinEvent(menu)

func _on_Server_pressed() -> void:
	joinEvent(menu)
