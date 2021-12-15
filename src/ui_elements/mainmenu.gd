extends Control

# --Variables--
enum MenuType {MAIN, JOIN, CREATE, SERVER}

onready var main_menu: Control = $MainMenu
onready var join_menu: Control = $Join
onready var create_menu: Control = $Create
onready var server_menu: Control = $Server

# --Interface--
func _ready():
	set_Visible_Menu(MenuType.MAIN)

func _on_Back_pressed():
	set_Visible_Menu(MenuType.MAIN)

func _on_GameJoinButton_pressed() -> void:
	set_Visible_Menu(MenuType.JOIN)

func _on_GameCreateButton_pressed() -> void:
	set_Visible_Menu(MenuType.CREATE)

func _on_ServerStartButton_pressed() -> void:
	set_Visible_Menu(MenuType.SERVER)

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
func _on_Join_pressed() -> void:
	assert(false, "Game start not implemented yet")
	
func _on_Create_pressed() -> void:
	assert(false, "Game start not implemented yet")

func _on_Server_pressed():
	assert(false, "Game start not implemented yet")
