extends Control

# --Private Functions--

func _ready():
	$Darken.hide()
	Scenes.setBase(self, "res://ui_elements/main_menu.tscn")

func _onBack():
	if $ExitMenu.visible:
		$ExitMenu.hide()
		$Darken.hide()
	else:
		$Darken.show()
		$ExitMenu.popup_centered()

# --Signal Functions--

func _on_Cancel_pressed():
	$ExitMenu.hide()
	$Darken.hide()

func _on_Exit_pressed():
	get_tree().quit()
