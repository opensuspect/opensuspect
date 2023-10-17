extends Control

# --Private Functions--

func _ready():
	Scenes.addChild(self,"res://ui_elements/main_menu.tscn")

func _onBack():
	Scenes.addChild(self,"res://ui_elements/exit_menu.tscn")
