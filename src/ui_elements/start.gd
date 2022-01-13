extends Control

enum menuType {MAIN, APPEARANCE, CLOSET, SETTINGS}

var currentMenu: int
var menuOrder: Array # Keeps track of the menu order, so back takes to menu before

# --Public Functions--

# Switch to the correct menu based on current menu
func switchMenu():
	_hideMenus()
	match currentMenu:
		menuType.MAIN: $MainMenu.show()
		menuType.APPEARANCE: $AppearanceEditor.show()
		menuType.CLOSET: 
			$Closet.show()
			$Closet.listItems()
		menuType.SETTINGS: $Settings.show()

func back() -> void:
	var index = menuOrder.size() - 1 # Get the index of the last item in menu order
	if index > 0:
		menuOrder.remove(index) # Remove the item at the index
		currentMenu = menuOrder.back() # Set current menu to the last item in the array
		switchMenu()	

# --Private Functions--

func _ready():
	currentMenu = menuType.MAIN
	switchMenu()
	menuOrder.append(currentMenu) # Add the current menu to menu order

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back()

## Hide all menus
func _hideMenus():
	$MainMenu.hide()
	$AppearanceEditor.hide()
	$Closet.hide()
	$Settings.hide()


func _on_menuSwitch(menu):
	match menu:
		"appearance": menu = menuType.APPEARANCE
		"closet": menu = menuType.CLOSET
		"settings": menu = menuType.SETTINGS
	if menu != menuOrder.back(): # Make sure we aren't trying to go to current menu
		currentMenu = menu # Set current menu to the menu enum
		menuOrder.append(currentMenu) # Append the new menu to menu order
		switchMenu() # Switch to the current menu

func _on_menuBack():
	back()
