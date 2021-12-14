extends Control

# --Variables--

enum MenuType {MAIN, CREATE, JOIN, SERVER}

onready var create_game_menu: Control = $CreateGame
onready var join_menu: Control = $JoinGame
onready var dedicated_menu: Control = $Server
onready var main_menu: Control = $Menu

# --Interface--
func _ready():
	set_Visible_Menu("main_menu")
	
func _on_Back_pressed():
	set_Visible_Menu("main_menu")

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
func _on_Create_pressed() -> void:
	assert(false, "Game start not implemented yet")

func _on_Join_pressed() -> void:
	assert(false, "Game start not implemented yet")

func _on_Host_pressed() -> void:
	assert(false, "Game start not implemented yet")
