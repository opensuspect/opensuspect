extends Control

onready var menuPlayer = $MainMenu/MainMenu/CenterPlayer/Player/MenuPlayer/Skeleton

# --Public Variables--

var menu
enum CurrentMenu {MAIN, APPEARANCE, SETTINGS}

# --Public Functions--

func changeMenu():
	_hideMenus() # Hide all the menus
	match menu: # Show only the correct menu
		CurrentMenu.MAIN: $MainMenu.visible = true
		CurrentMenu.APPEARANCE: $AppearanceEditor.visible = true

# --Private Functions--

func _ready():
	menu = CurrentMenu.MAIN # Default to main menu
	changeMenu() # Change the menu

# Hide each menu
func _hideMenus():
	$MainMenu.visible = false
	$AppearanceEditor.visible = false

# --Signal Functions--

# Show main menu from appearance menu
func _on_AppearanceEditor_menuBack():
	menu = CurrentMenu.MAIN
	menuPlayer.applyConfig() # Apply config to character
	changeMenu()

# Show appearance menu
func _on_MainMenu_menuAppearance():
	menu = CurrentMenu.APPEARANCE
	changeMenu()
