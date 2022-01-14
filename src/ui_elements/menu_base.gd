extends Control

# --Private Functions--

func _ready():
	Scenes.baseScene = self
	Scenes.overlay("res://ui_elements/main_menu.tscn")
