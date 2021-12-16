extends Control

# --Variables--
enum MenuType {MAIN, JOIN, CREATE, SERVER}

var menu

onready var main_menu: Control = $MainMenu
onready var join_menu: Control = $Join
onready var create_menu: Control = $Create
onready var server_menu: Control = $Server

# --Interface--
func _ready():
	menu = MenuType.MAIN
	set_Visible_Menu(menu)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		join_Event(menu)

func _on_Back_pressed():
	menu = MenuType.MAIN
	set_Visible_Menu(menu)

func _on_GameJoinButton_pressed() -> void:
	menu = MenuType.JOIN
	set_Visible_Menu(menu)

func _on_GameCreateButton_pressed() -> void:
	menu = MenuType.CREATE
	set_Visible_Menu(menu)

func _on_ServerStartButton_pressed() -> void:
	menu = MenuType.SERVER
	set_Visible_Menu(menu)

func _on_AppQuitButton_pressed() -> void:
	get_tree().quit()

func set_Visible_Menu(menu) -> void:
	hide_Menus()
	match menu:
		MenuType.MAIN: main_menu.visible = true
		MenuType.JOIN: join_menu.visible = true
		MenuType.CREATE: create_menu.visible = true
		MenuType.SERVER: server_menu.visible = true

func hide_Menus() -> void:
	main_menu.visible = false
	join_menu.visible = false
	create_menu.visible = false
	server_menu.visible = false

# --Backend--
func join_Event(menu):
	match menu:
		MenuType.MAIN:
			menu = MenuType.JOIN
			set_Visible_Menu(menu)
		MenuType.JOIN: assert(false, "Game start not implemented yet")
		MenuType.CREATE: assert(false, "Game start not implemented yet")
		MenuType.SERVER: assert(false, "Game start not implemented yet")

func _on_Join_pressed() -> void:
	join_Event(menu)
	
func _on_Create_pressed() -> void:
	join_Event(menu)

func _on_Server_pressed():
	join_Event(menu)
