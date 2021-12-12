extends Control

# --Variables--
enum MenuType {MAIN, CREATE, JOIN, SERVER}

onready var create_game_menu: MarginContainer = $CreateGameMenu
onready var join_menu: MarginContainer = $JoinGameMenu
onready var dedicated_menu: MarginContainer = $DedicatedMenu
onready var main_menu: MarginContainer = $MainMenu

# --Interface--
func _ready():
	set_Visible_Menu(MenuType.MAIN)

func _on_BackButton_pressed() -> void:
	set_Visible_Menu(MenuType.MAIN)

func _on_GameCreateButton_pressed() -> void:
	set_Visible_Menu(MenuType.CREATE)

func _on_GameJoinButton_pressed() -> void:
	set_Visible_Menu(MenuType.JOIN)
	
func _on_ServerStartButton_pressed() -> void:
	set_Visible_Menu(MenuType.SERVER)

func _on_AppQuitButton_pressed() -> void:
	get_tree().quit()

func set_Visible_Menu(menu) -> void:
	hide_Menus()
	match menu:
		MenuType.MAIN: main_menu.visible = true
		MenuType.CREATE: create_game_menu.visible = true
		MenuType.JOIN: join_menu.visible = true
		MenuType.SERVER: dedicated_menu.visible = true

func hide_Menus() -> void:
	main_menu.visible = false
	create_game_menu.visible = false
	join_menu.visible = false
	dedicated_menu.visible = false

# --Backend--
func _on_CreateGameStarter_pressed() -> void:
	var portField: LineEdit = $CreateGameMenu/Menupoints/PortContainer/PortInput
	var nameField: LineEdit = $CreateGameMenu/Menupoints/NameContainer/NameInput
	var port: int = int(portField.text)
	var name: String = nameField.text
	Connections.createServer(port, name)

func _on_JoinGameStarter_pressed() -> void:
	var portField: LineEdit = $JoinGameMenu/Menupoints/PortContainer/PortInput
	var ipField: LineEdit = $JoinGameMenu/Menupoints/HostNameContainer/HostNameInput
	var nameField: LineEdit = $JoinGameMenu/Menupoints/NameContainer/NameInput
	var port: int = int(portField.text)
	var host: String = ipField.text
	var name: String = nameField.text
	Connections.joinGame(host, port, name)

func _on_DedicatedStarter_pressed() -> void:
	assert(false, "Dedicated server not implemented yet")
