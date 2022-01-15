extends Control

enum menuType {MAIN, APPEARANCE, CLOSET, SETTINGS}

var currentMenu: int
var menuOrder: Array # Keeps track of the menu order, so back takes to menu before

# --Public Functions--

# Switch to the correct menu based on current menu
func switchMenu() -> void:
	_hideMenus() ## Hides all windows
	match currentMenu:
		menuType.MAIN: $MainMenu.show() ## Main menu
		menuType.APPEARANCE: $AppearanceEditor.show() ## Appearance editor
		menuType.CLOSET: ## Closet
			$Closet.show() ## Opens closet
			$Closet.listItems() ## Populates closet with items
		menuType.SETTINGS: $Settings.show() ## Settings
		_: assert(false, "Unreachable")

func back() -> void:
	## If we have menu on stack
	if menuOrder.size() > 0:
		menuOrder.pop_back() ## Remove last item
		currentMenu = menuOrder.back() ## Set last element as current menu
		switchMenu()

# --Private Functions--

func _ready() -> void:
	## Switch to main menu
	currentMenu = menuType.MAIN
	switchMenu()
	menuOrder.append(currentMenu) ## Put main menu on stack

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		back()

## Hide all menus
func _hideMenus() -> void:
	$MainMenu.hide()
	$AppearanceEditor.hide()
	$Closet.hide()
	$Settings.hide()


func _on_menuSwitch(strMenu: String):
	var menu: int
	## Checks menu type
	match strMenu:
		"appearance": menu = menuType.APPEARANCE ## Appearance
		"closet": menu = menuType.CLOSET ## Closet
		"settings": menu = menuType.SETTINGS ## Settings
		_: assert(false, "Unreachable")
	if menu != menuOrder.back(): ## Make sure we aren't trying to go to current menu
		currentMenu = menu ## Set current menu to the menu enum
		menuOrder.append(currentMenu) ## Append new menu to menu order
		switchMenu() ## Switch to new current menu

func _on_menuBack() -> void:
	back()
