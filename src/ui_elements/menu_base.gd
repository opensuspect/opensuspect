extends Control

# --Private Functions--

func _ready():
	if Scenes.baseScene == null:
		Scenes.setBase(self, "res://ui_elements/main_menu.tscn")

func _onBack():
	Scenes.overlay("res://ui_elements/exit_menu.tscn")
