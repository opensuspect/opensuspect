extends Control

onready var menuPlayer = $MainMenu/MainMenu/CenterPlayer/Player/MenuPlayer/Skeleton

var menu
enum CurrentMenu {MAIN, APPEARANCE, SETTINGS}

func changeMenu():
	_hideMenus()
	match menu:
		CurrentMenu.MAIN: $MainMenu.visible = true
		CurrentMenu.APPEARANCE: $AppearanceEditor.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = CurrentMenu.MAIN
	changeMenu()

func _hideMenus():
	$MainMenu.visible = false
	$AppearanceEditor.visible = false

func _on_AppearanceEditor_menuBack():
	menu = CurrentMenu.MAIN
	menuPlayer.applyConfig()
	changeMenu()

func _on_MainMenu_menuAppearance():
	menu = CurrentMenu.APPEARANCE
	changeMenu()
