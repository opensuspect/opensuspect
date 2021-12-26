extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var menu
enum CurrentMenu {MAIN, APPEARANCE, SETTINGS}

func changeMenu():
	_hideMenus()
	match menu:
		CurrentMenu.MAIN: $MainMenu.visible = true
		CurrentMenu.APPEARANCE: $AppearanceEditor.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = CurrentMenu.APPEARANCE
	changeMenu()

func _hideMenus():
	$MainMenu.visible = false
	$AppearanceEditor.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
